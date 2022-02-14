#Qu'est-ce que le projet PageRank ? 

Ce projet a été réalisé en première Année dans la filière de Sciences du Numérique à l'ENSEEIHT par deux étudiants (Nadesan KIRUPANANTHAN et Tom HEURTEBISE).
Il avait pour objectif de prendre les noeuds dans un réseau quelconques donnés (notez qu'un réseau est assimilable à des pages internet qui renvoient les unes 
vers les autres) et d'en tirer une hiérarchie en attribuant à chacun de ces noeuds un poids (déterminés par des formules mathéméthiques). 
Cette méthode se nomme pageRank puisqu'il s'agit d'une méthode qui a été utilisée par Google pour présenter les résultats lors d'une recherche internet. En effet, 
les noeuds ayant le plus de poids apparaissent logiquement en premier. 

#Comment compiler le projet ?

Pour compiler gnatmake -gnatwa -gnata -g -pg pagerank.adb

#Comment tester le projet ?

ex : ./pagerank -P -I 150 -A 0.90 exemple_sujet.net

Les paramètres -P, -I et -A sont optionnels. S’ils ne sont pas donnés, des valeurs par défaut sont utilisées. L’option -I permet de spécifier le nombre maximal d’itérations 
nécessaires pour calculer le poids de chaque noued (on utilise une méthode itérative) et l’option -A de modifier la valeur d’alpha qui est un facteur intervenant dans le calcul des poids. 
Par défaut, on utilisera alpha = 0:85 et 150 itérations au maximum. Le paramètre -P permet d’utiliser l’implantation matricielle pleine. Par défaut, on lance l’implantation avec des matrices creuses.

#Complément d'informations

Veuillez vous référer à la section docs ou figurent le rapport du projet ainsi que le sujet initial pour de plus amples informations.
