# Musicart sur Kubernetes (minikube)

Déploiement du projet perso Musicart (Symfony + Angular + MySQL) pour mettre en pratique Ingress,
NetworkPolicy et Helm.

## Secrets (non versionnés)

`php-secret` et `jwt-secret` contiennent de vraies valeurs sensibles (clé privée JWT, mot de passe DB)
et ne sont **volontairement pas** définis en YAML dans ce repo, ni dans le chart Helm. Ils sont créés
directement dans le cluster via des commandes imperative `kubectl create secret` :

```bash
kubectl create secret generic jwt-secret -n musicart \
  --from-file=private.pem=/Users/theovm/Documents/Projets Dev/Musicart/Musicart_Symfony/config/jwt/private.pem \
  --from-file=public.pem=/Users/theovm/Documents/Projets Dev/Musicart/Musicart_Symfony/config/jwt/public.pem

kubectl create secret generic php-secret -n musicart \
  --from-literal=DATABASE_URL="mysql://musicart:musicart-dev-password@mysql:3306/musicart?serverVersion=8.2&charset=utf8mb4" \
  --from-literal=JWT_PASSPHRASE="<valeur de JWT_PASSPHRASE dans Musicart_Symfony/.env>"
```

`mysql-secret` ne contient que des mots de passe de dev bidons, sans conséquence — celui-là est
généré par le chart Helm (valeurs par défaut dans `musicart-chart/values.yaml`), pas de commande à
part.

## Helm — pourquoi

Au départ, chaque ressource (Deployment, Service, Ingress, NetworkPolicy...) était un fichier YAML
séparé, appliqué un par un avec `kubectl apply -f`. **Helm** est le gestionnaire de paquets de
Kubernetes : il regroupe tous ces fichiers dans un **chart** (un dossier avec des templates YAML +
un `values.yaml` qui centralise ce qui varie — tag d'image, nombre de replicas, host de l'ingress).
Une seule commande (`helm install`/`helm upgrade`) déploie ou met à jour tout d'un coup, et Helm
garde un historique des versions déployées (`helm rollback`), comme `kubectl rollout undo` mais
pour l'ensemble de l'appli plutôt qu'un seul Deployment.

## Déploiement (Helm)

Tous les manifests (sauf `namespace.yaml` et les deux secrets sensibles ci-dessus) sont regroupés
dans le chart [`musicart-chart/`](./musicart-chart/) : un `Chart.yaml`, un `values.yaml` (images,
replicas, host de l'ingress, mots de passe MySQL de dev...) et les templates YAML dans
`musicart-chart/templates/`.

```bash
minikube addons enable ingress
```

⚠️ **Ne pas builder les images dans le daemon docker de minikube** (`eval $(minikube docker-env)`) :
la VM minikube par défaut n'a que 2 CPU / ~2-4 Go de RAM, largement insuffisant pour compiler
Angular (6 `ng build` enchaînés) — le build reste bloqué indéfiniment. Builder sur le daemon de
l'hôte (Docker Desktop, bien plus de ressources) puis charger l'image dans minikube :

```bash
docker build -t musicart-php:local -f /Users/theovm/Documents/Projets Dev/Musicart/Musicart_Symfony/Dockerfile /Users/theovm/Documents/Projets Dev/Musicart/Musicart_Symfony
docker build -t musicart-nginx:local -f /Users/theovm/Documents/Projets Dev/Musicart/Musicart_Symfony/Dockerfile.nginx /Users/theovm/Documents/Projets Dev/Musicart/Musicart_Symfony
docker build -t musicart-frontend:local /Users/theovm/Documents/Projets Dev/Musicart/Musicart_angular

minikube image load musicart-php:local
minikube image load musicart-nginx:local
minikube image load musicart-frontend:local
```

Puis :

```bash
kubectl apply -f namespace.yaml
# (créer jwt-secret et php-secret, voir ci-dessus)

helm install musicart ./musicart-chart -n musicart

# migrations Symfony (une fois les pods up)
kubectl exec -n musicart deploy/php -- php bin/console doctrine:migrations:migrate --no-interaction
```

Pour appliquer un changement (ex: modifier `values.yaml`, ou après un `minikube image load` d'une
nouvelle image) :

```bash
helm upgrade musicart ./musicart-chart -n musicart

# Voir l'historique des versions déployées, et revenir en arrière si besoin
helm history musicart -n musicart
helm rollback musicart 1 -n musicart

# Prévisualiser le YAML généré sans rien appliquer (utile pour vérifier un template)
helm template musicart ./musicart-chart
```

### Accès depuis le navigateur

Avec le driver Docker sur Mac, le réseau du cluster n'est pas directement routable depuis l'hôte :
il faut un tunnel (nécessite `sudo`, donc à lancer soi-même dans un terminal, laissé ouvert) :

```bash
# terminal 1 : garder ouvert
minikube tunnel

# terminal 2 : une seule fois
echo "127.0.0.1 musicart.local" | sudo tee -a /etc/hosts
```

Puis ouvrir http://musicart.local dans le navigateur.

Pour un test rapide sans toucher `/etc/hosts` ni lancer de tunnel (ce qu'on a utilisé pour valider
que l'Ingress route bien `/` → frontend et `/api` + `/authentication_token` → backend) :

```bash
kubectl port-forward -n ingress-nginx svc/ingress-nginx-controller 18080:80
curl -H "Host: musicart.local" http://localhost:18080/
curl -H "Host: musicart.local" http://localhost:18080/api/n_f_t_collections
```

### Recréer une image après un changement de code

Si on modifie le code (ex: un fix dans `migrations/`), il faut rebuilder ET forcer minikube à
prendre le nouveau digest — `minikube image load` seul ne remplace pas une image déjà tirée par un
pod en cours d'exécution (`imagePullPolicy: IfNotPresent`) :

```bash
kubectl scale deployment php -n musicart --replicas=0
minikube image load musicart-php:local
kubectl scale deployment php -n musicart --replicas=1
```

### Restaurer un dump SQL

Après un premier déploiement, la base MySQL est vide : les migrations Doctrine créent le
**schéma** (les tables), pas les **données**. Pour importer un export existant (ex: dump
phpMyAdmin) :

```bash
# 1. Vider les tables actuelles (elles sont vides après un premier déploiement, donc sans risque)
kubectl exec -n musicart deploy/mysql -- mysql -umusicart -p'musicart-dev-password' musicart -e "
SET FOREIGN_KEY_CHECKS=0;
DROP TABLE IF EXISTS address, category, doctrine_migration_versions, nft, nftcollection, nft_category, user;
SET FOREIGN_KEY_CHECKS=1;"

# 2. Importer le dump (le fichier .sql doit contenir les CREATE TABLE + INSERT, sans USE/CREATE DATABASE)
cat /Users/theovm/Documents/Projets Dev/Musicart/musicart_k8s/musicart.sql | kubectl exec -i -n musicart deploy/mysql -- mysql -umusicart -p'musicart-dev-password' musicart

# 3. Rejouer les migrations Symfony pour rattraper les migrations plus récentes que le dump
kubectl exec -n musicart deploy/php -- php bin/console doctrine:migrations:migrate --no-interaction
```

⚠️ **Piège rencontré** : l'import a échoué sur une contrainte de clé étrangère
(`Cannot add or update a child row`) parce qu'une ligne de la table `user` référençait un
`address_id` qui n'existait pas dans le dump (donnée déjà incohérente à la source). Diagnostic :

```bash
kubectl exec -n musicart deploy/mysql -- mysql -umusicart -p'musicart-dev-password' musicart \
  -e "SELECT id, address_id FROM user; SELECT id FROM address;"
```

Puis correction (le champ est nullable) avant d'ajouter la contrainte manuellement :

```bash
kubectl exec -n musicart deploy/mysql -- mysql -umusicart -p'musicart-dev-password' musicart -e "
UPDATE user SET address_id = NULL WHERE id = <id concerné>;
ALTER TABLE user ADD CONSTRAINT FK_8D93D649F5B7AF75 FOREIGN KEY (address_id) REFERENCES address (id);"
```

### Piège : routes Angular en 404 ou en listing de dossier Apache

Angular est une SPA : le **Router Angular** (côté navigateur) décide quoi afficher pour une URL
comme `/nfts` ou `/users/42` — il n'y a pas vraiment de fichier `nfts/index.html` sur le serveur.
Ça marche quand on navigue *depuis* l'app (clic sur un lien, pas de vrai rechargement de page),
mais **pas** quand on ouvre l'URL directement ou qu'on rafraîchit la page : Apache va chercher un
fichier qui n'existe pas.

Deux symptômes observés :
1. Une 404 franche pour les routes qui n'ont aucun dossier correspondant sur le disque.
2. Un **"Index of /nfts"** (listing de fichiers) pour `/nfts` : le `Dockerfile` du frontend fait
   `COPY --from=angular /app/dist/nfts/create ./nfts/create`, ce qui crée *implicitement* le
   dossier `/nfts` sur le disque (comme parent de `create`), sans `index.html` dedans. Apache,
   avec `Options Indexes` activé par défaut, affiche alors la liste des fichiers de ce dossier au
   lieu d'une erreur.

**Fix** (dans `Musicart_angular/Dockerfile` et `Musicart_angular/.htaccess`) : activer
`mod_rewrite` + `AllowOverride All`, et ajouter un `.htaccess` qui :
- laisse passer les vrais fichiers statiques (JS, CSS, images) ;
- laisse passer les dossiers qui contiennent vraiment un `index.html` (ex: `/login/`,
  `/nfts/create/`, pré-générés par le Dockerfile) ;
- renvoie tout le reste vers `/index.html`, pour que le Router Angular prenne la main.

```apache
Options -Indexes

RewriteEngine On

RewriteCond %{REQUEST_FILENAME} -f
RewriteRule ^ - [L]

RewriteCond %{REQUEST_FILENAME}/index.html -f
RewriteRule ^ - [L]

RewriteRule ^ /index.html [L]
```

## NetworkPolicy — cloisonner le trafic interne

Par défaut, tous les pods du cluster peuvent se parler entre eux, même entre namespaces. Une
**NetworkPolicy** cible des pods via un `podSelector` et bascule leur trafic (ingress et/ou egress)
en "deny by default" : dès qu'une policy sélectionne un pod pour une direction donnée, seul ce qui
est explicitement autorisé passe.

⚠️ **Prérequis** : le CNI par défaut de minikube (`kindnet`) n'applique **pas** ces règles (il assure
juste la connectivité, sans moteur de filtrage). Il faut un CNI qui les supporte, ex. Calico —
ce qui nécessite de recréer le cluster (`minikube delete` puis `minikube start --driver=docker
--cni=calico`), donc de tout redéployer (images, secrets, migrations, dump SQL).

### Policies mises en place

Une policy par composant, qui n'autorise que le flux réellement nécessaire — templatisées dans
`musicart-chart/templates/`, activées par défaut (`networkPolicy.enabled: true` dans
`values.yaml`) :

- `networkpolicy-mysql.yaml` : `mysql` n'accepte du trafic entrant
  que depuis les pods `app=php`, sur le port 3306.
- `networkpolicy-php.yaml` : `php` n'accepte que depuis les pods
  `app=nginx-backend`, sur le port 9000 (FastCGI).
- `networkpolicy-nginx.yaml` : `nginx-backend` n'accepte que depuis
  le namespace `ingress-nginx` (le contrôleur d'Ingress), sur le port 80.
- `networkpolicy-frontend.yaml` : même chose pour `frontend`.

Résultat : `mysql` et `php` ne sont plus joignables que depuis leur "voisin légitime" — même un
autre pod du même namespace (ex: `frontend`) ne peut plus les atteindre directement — alors que le
chemin utilisateur normal (Ingress → frontend / nginx → php → mysql) continue de fonctionner
normalement.

Pour désactiver temporairement (ex: debug) : `helm upgrade musicart ./musicart-chart -n musicart
--set networkPolicy.enabled=false`.

```bash
kubectl get networkpolicy -n musicart
```

### Vérifier l'enforcement

```bash
# Bloqué : frontend n'a plus le droit de parler à mysql directement
kubectl exec -n musicart deploy/frontend -- nc -zv -w 3 mysql 3306
# → "Operation timed out"

# Toujours autorisé : php -> mysql
kubectl exec -n musicart deploy/php -- nc -zv -w 3 mysql 3306
# → "mysql (...:3306) open"

# Toujours autorisé : l'app complète via l'Ingress
kubectl port-forward -n ingress-nginx svc/ingress-nginx-controller 18080:80 &
curl -H "Host: musicart.local" http://localhost:18080/api/n_f_t_collections
```

### Piège : PVC recréée = même dossier disque

Le storage-provisioner de minikube mappe les PVC sur un chemin déterministe
`/tmp/hostpath-provisioner/<namespace>/<pvc-name>`. Si un pod MySQL a été tué en plein
`docker-entrypoint` init (ex: manque de ressources), puis qu'on supprime/recrée le PVC, le nouveau
volume peut retomber sur le **même** dossier physique non nettoyé → MySQL ne réinitialise pas et
garde un état de mots de passe incohérent (`Access denied` même avec le bon secret). Pour repartir
propre :

```bash
kubectl scale deployment mysql -n musicart --replicas=0
minikube ssh -- "sudo rm -rf /tmp/hostpath-provisioner/musicart/mysql-data/*"
kubectl scale deployment mysql -n musicart --replicas=1
```
