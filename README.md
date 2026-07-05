# Musicart sur Kubernetes (minikube)

Déploiement du projet perso Musicart (Symfony + Angular + MySQL) pour mettre en pratique Ingress.

## Secrets (non versionnés)

`php-secret` et `jwt-secret` contiennent de vraies valeurs sensibles (clé privée JWT, mot de passe DB)
et ne sont **volontairement pas** définis en YAML dans ce repo. Ils sont créés directement dans le
cluster via des commandes imperative `kubectl create secret` :

```bash
kubectl create secret generic jwt-secret -n musicart \
  --from-file=private.pem=/Users/theovm/Documents/Projets Dev/Musicart/Musicart_Symfony/config/jwt/private.pem \
  --from-file=public.pem=/Users/theovm/Documents/Projets Dev/Musicart/Musicart_Symfony/config/jwt/public.pem

kubectl create secret generic php-secret -n musicart \
  --from-literal=DATABASE_URL="mysql://musicart:musicart-dev-password@mysql:3306/musicart?serverVersion=8.2&charset=utf8mb4" \
  --from-literal=JWT_PASSPHRASE="<valeur de JWT_PASSPHRASE dans Musicart_Symfony/.env>"
```

`mysql-secret.yaml` ne contient que des mots de passe de dev bidons, sans conséquence — celui-là reste versionné.

## Déploiement

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
kubectl apply -f mysql-secret.yaml -f mysql-pvc.yaml -f mysql-deployment.yaml -f mysql-service.yaml
kubectl apply -f php-deployment.yaml -f php-service.yaml
kubectl apply -f nginx-deployment.yaml -f nginx-service.yaml
kubectl apply -f frontend-deployment.yaml -f frontend-service.yaml
kubectl apply -f ingress.yaml

# migrations Symfony (une fois les pods up)
kubectl exec -n musicart deploy/php -- php bin/console doctrine:migrations:migrate --no-interaction
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
