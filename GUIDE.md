# Musicart sur Kubernetes — guide pas à pas

Ce document explique, dans l'ordre, ce qui a été mis en place pour faire tourner Musicart
(Symfony + Angular + MySQL) sur ton cluster minikube, et donne les commandes du quotidien pour
démarrer, arrêter et surveiller l'application.

---

## 1. Vue d'ensemble

```
                        Ingress (musicart.local)
                                │
                ┌───────────────┴───────────────┐
                │                                │
           / (tout sauf /api)              /api, /authentication_token
                │                                │
                ▼                                ▼
        Service "frontend"                Service "nginx-backend"
        (Angular, servi par Apache)                │
                                                    ▼
                                            Service "nginx" (reverse proxy)
                                                    │
                                                    ▼
                                            Service "php" (Symfony, PHP-FPM)
                                                    │
                                                    ▼
                                            Service "mysql" (base de données)
```

Tout tourne dans le namespace **`musicart`**, isolé du reste de ton playground (`dev`, `prod`, etc.).

---

## 2. Ce qui a été fait, étape par étape

1. **Corrigé le code Angular** : les 4 fichiers `service/*.service.ts` appelaient l'API en dur
   (`https://127.0.0.1:8000/...`). Remplacé par des chemins relatifs (`/api/...`,
   `/authentication_token`) pour que ça marche derrière n'importe quel nom d'hôte, une fois passé
   par l'Ingress (même origine que le frontend, donc pas de souci CORS).

2. **Rendu les images "buildables" pour Kubernetes** :
   - `Musicart_Symfony/Dockerfile` : ajout de `COPY . /code` (le docker-compose original comptait
     sur un bind-mount, qui n'existe pas dans un pod k8s) + passage en `php:8.4-fpm-alpine` (le
     `vendor/` installé localement exigeait PHP ≥ 8.4).
   - `Musicart_Symfony/Dockerfile.nginx` (nouveau) : une image nginx autonome qui embarque
     `public/` et `nginx.conf`, pour remplacer le bind-mount du docker-compose.
   - `Musicart_angular/Dockerfile` : déjà autonome (multi-stage build → image Apache), rien à
     changer.

3. **Écrit les manifests Kubernetes** dans `musicart/` : `namespace.yaml`, MySQL (Secret + PVC +
   Deployment + Service), PHP (Deployment + Service), nginx backend (Deployment + Service),
   frontend (Deployment + Service), et l'**Ingress** (`ingress.yaml`) qui route tout ça sous un
   seul host `musicart.local`.

4. **Créé les secrets sensibles directement dans le cluster** (clé JWT, mot de passe DB) via
   `kubectl create secret`, sans jamais les écrire dans un fichier versionné — voir la section
   "Secrets" du `README.md` du dossier.

5. **Buildé les images et déployé** : build sur le daemon Docker de l'hôte (la VM minikube est
   trop petite pour compiler Angular), puis `minikube image load`, puis `kubectl apply -f`.

6. **Corrigé un bug préexistant** dans `migrations/Version20250408071428.php` (une migration
   Doctrine non-idempotente qui plantait sur une base neuve) pour pouvoir lancer
   `doctrine:migrations:migrate`.

7. **Activé l'addon Ingress** de minikube et vérifié le routage (`/`, `/api`,
   `/authentication_token`) via `kubectl port-forward`, sans toucher à `/etc/hosts`.

8. **Restauré un dump SQL réel** (`musicart.sql`, export phpMyAdmin) dans la base MySQL du cluster,
   qui était vide après le premier déploiement (les migrations créent le schéma, pas les données).
   Voir la section "Restaurer un dump SQL" du `README.md` pour la procédure et le piège rencontré
   (une contrainte de clé étrangère orpheline dans les données).

9. **Corrigé le routage Angular côté serveur** : les URLs gérées par le Router Angular
   (`/nfts`, `/users/42`, etc.) renvoyaient une erreur ou un listing de dossier Apache quand on y
   accédait directement (au lieu de naviguer depuis l'app). Ajouté un `.htaccess` + activé
   `mod_rewrite` dans `Musicart_angular/Dockerfile` pour que toute route inconnue du système de
   fichiers retombe sur `index.html`, laissant Angular décider quoi afficher. Voir "Piège : routes
   Angular en 404 ou listing de dossier" dans le `README.md`.

10. **Cloisonné le trafic interne avec des NetworkPolicy** : recréé le cluster avec le CNI Calico
    (`minikube start --driver=docker --cni=calico`, seul un CNI comme Calico applique réellement
    ces règles — le CNI par défaut de minikube les ignore), puis ajouté 4 `NetworkPolicy` qui
    n'autorisent que le trafic strictement nécessaire (`frontend`/`nginx` ← Ingress uniquement,
    `php` ← `nginx` uniquement, `mysql` ← `php` uniquement). Vérifié qu'un pod qui n'a pas le droit
    (ex: `frontend` vers `mysql`) se fait bloquer, alors que le chemin utilisateur normal continue
    de marcher. Voir "NetworkPolicy" dans le `README.md`.

11. **Regroupé tous les manifests dans un chart Helm** (`musicart-chart/`) : les ~15 fichiers YAML
    séparés (Deployments, Services, Ingress, NetworkPolicy) sont devenus des templates
    paramétrables via `values.yaml` (images, replicas, host, mots de passe MySQL de dev). Le
    déploiement se fait maintenant en une commande (`helm install`/`helm upgrade`) au lieu d'une
    dizaine de `kubectl apply -f`, avec un historique de versions et un rollback possibles. Les
    secrets sensibles (`jwt-secret`, `php-secret`) restent créés à part, hors du chart, comme
    avant. Voir "Helm" dans le `README.md`.

---

## 3. Démarrer l'application (au quotidien)

Si tout est déjà déployé (cas normal après le premier setup) et que tu redémarres juste ta machine :

```bash
# 1. Démarrer Docker Desktop s'il n'est pas lancé
open -a Docker

# 2. Démarrer le cluster minikube
minikube start --driver=docker

# 3. Vérifier que tout redémarre correctement
kubectl get pods -n musicart
```

Les Deployments redémarrent automatiquement leurs pods — pas besoin de ré-appliquer les manifests
ni de recréer les secrets (ils sont stockés dans le cluster, persistés avec lui).

⚠️ Le cluster utilise maintenant le CNI **Calico** (nécessaire pour que les `NetworkPolicy`
fonctionnent réellement). Ça ne change rien pour un simple `minikube stop` / `minikube start` —
mais si un jour tu fais `minikube delete`, il faudra repartir avec
`minikube start --driver=docker --cni=calico` (sans quoi les policies resteront présentes mais
n'auront plus aucun effet), puis tout redéployer (images, secrets, migrations, dump SQL).

### Accéder à l'application dans le navigateur

Il faut un tunnel réseau (le driver Docker sur Mac n'expose pas directement le réseau du cluster) :

```bash
# Terminal à part, à laisser ouvert tout le temps de l'utilisation :
minikube tunnel
```

Puis, **une seule fois** (ça reste enregistré) :

```bash
echo "127.0.0.1 musicart.local" | sudo tee -a /etc/hosts
```

Ouvre ensuite **http://musicart.local** dans le navigateur.

---

## 4. Arrêter l'application

Plusieurs niveaux, du plus léger au plus radical :

```bash
# Arrêter juste le tunnel réseau : Ctrl+C dans son terminal

# Mettre le cluster en pause (garde tout l'état, redémarre vite avec `minikube start`)
minikube stop

# Supprimer complètement le cluster (perd tout : données MySQL, secrets, tout est à refaire)
minikube delete
```

Pour la vie de tous les jours, `minikube stop` / `minikube start` suffit largement.

---

## 5. Commandes utiles pour gérer Musicart

```bash
# Voir l'état de tous les pods de l'appli
kubectl get pods -n musicart

# Voir les logs d'un composant (ex: php, nginx, mysql, frontend)
kubectl logs -n musicart deploy/php
kubectl logs -n musicart deploy/php -f          # en continu (comme tail -f)

# Ouvrir un shell dans un pod pour debug
kubectl exec -it -n musicart deploy/php -- sh

# Lancer une commande Symfony (ex: relancer les migrations après une nouvelle migration)
kubectl exec -n musicart deploy/php -- php bin/console doctrine:migrations:migrate --no-interaction

# Redémarrer un composant (ex: après avoir changé une variable d'env dans le manifest)
kubectl rollout restart deployment/php -n musicart

# Voir tout ce qui tourne dans le namespace d'un coup
kubectl get all -n musicart

# Historique des déploiements Helm, et rollback si besoin
helm history musicart -n musicart
helm rollback musicart <revision> -n musicart
```

### Après une modification du code (Symfony ou Angular)

Il faut rebuilder l'image concernée et forcer minikube à prendre la nouvelle version :

```bash
# Exemple pour le backend PHP
docker build -t musicart-php:local -f /Users/theovm/Documents/Projets Dev/Musicart/Musicart_Symfony/Dockerfile /Users/theovm/Documents/Projets Dev/Musicart/Musicart_Symfony

kubectl scale deployment php -n musicart --replicas=0
minikube image load musicart-php:local
kubectl scale deployment php -n musicart --replicas=1
```

(Remplacer `php`/`musicart-php` par `nginx`/`musicart-nginx` ou `frontend`/`musicart-frontend`
selon ce qui a changé — le Dockerfile et le dossier source correspondants dans les commandes.)

---

## 6. En cas de souci

Voir la section **"Piège"** du `README.md` du dossier `musicart/` pour les deux problèmes déjà
rencontrés (build trop lent dans la VM minikube, PVC MySQL qui garde un état corrompu après
suppression) et comment les résoudre.
