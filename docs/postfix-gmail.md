# Configuration de Postfix avec Gmail (relais SMTP)

## 1. Installation
```bash
sudo apt update
sudo apt install postfix libsasl2-modules mailutils
```

## 2. Identifiants (mot de passe d'application Gmail)

Créer un **mot de passe d'application** dans les paramètres de sécurité du compte Google (validation en deux étapes requise). Ne jamais utiliser le mot de passe principal et ne jamais publier ce fichier.

```bash
sudo mkdir -p /etc/postfix/sasl
sudo nano /etc/postfix/sasl/sasl_passwd
```
Contenu :
```
[smtp.gmail.com]:587   votre_email@gmail.com:mot_de_passe_application
```
```bash
sudo postmap /etc/postfix/sasl/sasl_passwd
sudo chown root:root /etc/postfix/sasl/sasl_passwd /etc/postfix/sasl/sasl_passwd.db
sudo chmod 600 /etc/postfix/sasl/sasl_passwd /etc/postfix/sasl/sasl_passwd.db
```

## 3. Configuration de `/etc/postfix/main.cf`
```
relayhost = [smtp.gmail.com]:587

smtp_sasl_auth_enable = yes
smtp_sasl_security_options = noanonymous
smtp_sasl_password_maps = hash:/etc/postfix/sasl/sasl_passwd

smtp_tls_security_level = encrypt
smtp_tls_CAfile = /etc/ssl/certs/ca-certificates.crt
```

## 4. Redémarrage et test
```bash
sudo systemctl restart postfix
```
```
sendmail votre_email@gmail.com
From: server@ubuntu
Subject: Test Postfix Gmail
Bonjour, ceci est un test.
```
(terminer par `Ctrl+D`)

En cas de problème : `sudo tail -f /var/log/mail.log`
