# Estos comandos, evitan que docker por defecto abra todos los puertos mapeados en iptables 
 
 firewall-cmd --permanent --direct --remove-chain ipv4 filter DOCKER-USER
 firewall-cmd --permanent --direct --remove-rules ipv4 filter DOCKER-USER
 firewall-cmd --permanent --direct --add-chain ipv4 filter DOCKER-USER
 
 firewall-cmd --permanent --direct --add-rule ipv4 filter DOCKER-USER 1   -m conntrack   --ctstate RELATED,ESTABLISHED -j ACCEPT   -m comment --comment 'Allow containers to connect to the outside world'
 firewall-cmd --permanent --direct --add-rule ipv4 filter DOCKER-USER 1   -j RETURN   -s 172.17.0.0/16   -m comment --comment 'allow internal docker communication'
