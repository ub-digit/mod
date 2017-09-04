# mod
Template Based Operation System Distribution (Mallbaserad OperativsystemsDistribution)

1. Logga in på intra och bli installer

	```code
	$ ssh gubnm@130.241.35.208
	$ sudo su - installer
	```

2. Gå till boot-settings i offpc/netboot-katalogen 
```code
 $ cd offpc/netboot/boot-settings
 ```

3. Redigera en boot-settingsfil under namnet boot-settings.sh
   Här jobbar vi enbart med elevpc. Så beroende på vad du vill göra så kör du ett av följande kommandon:
   ```code
   $ cp boot-settings-clone-elevpc.sh boot-settings.sh
   $ cp boot-settings-install-elevpc.sh boot-settings.sh
```
3a Kloning av elevpc
   - Ersätt innehållet i IPDEC med det IP-nummer som Silva angav
   - Ersätt innehållet i CLONE_CMT med den kommentaren som Silva angav

3b Installation av elevpc
   - Ersätt IPDEC med de IP-nummer Silva angett. Kan vara en mellanslagsseparerad lista över flera IP-adresser.
   - Ersätt IMG_NAME med det mallnamn Silva angivit.

Om man kör utan OUTPUT_PATH så skall resultatfilerna hamna i /home/installer/offpc/netboot/pxe/pxelinux.cfg/

Kloning:
I /mnt/data/MOD/IMAGES_test/elevpc/ kan man se om en kloning är klar genom att den döpt om en katalog som heter MAC-adressen utan kolon. Den skall ha döpts om till MaskinNamn_DatumFörFärdigställande_IpNummer.
