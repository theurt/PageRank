-- Spécification du module Récupération_Argument qui permet de récupérer les arguments de la ligne de commande de pagerank
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

generic

   type T_alpha is digits <>;               -- alpha peut être plus ou moins précis

package Recuperation_Argument is

   Missing_Arguments_Value_Error : exception;
   Invalid_Type_Arguments_Error : exception;
   Invalid_Name_Option_Error : exception;
   None_Argument_Error : exception;
   File_Absent_Error : exception;
   Missing_Options_Error : exception;
   Too_Many_Argument_Error : exception;

   -- Nom : Recuperer_valeurs_option
   -- Semantique : Renvoit la valeur de chaque paramètre de la ligne de commande
   -- Paramètre(s) :
   -- alpha : out reel (de précision variable);           -- facteur de pondération défini dans le sujet
   -- iteration : out Integer;                            -- nombre d'itération
   -- naive : out Boolean;                                -- l'utilisateur veut-il utiliser des matrices pleines ou creuses ?
   -- Nom_fcihier : out Unbounded_String;                 -- fichier.net
   -- Pre : True
   -- Post : alpha < T_alpha(1) and alpha > T_alpha(0) and iteration >= 1
   -- and To_String(Nom_fichier)(Length(Nom_fichier)-4 ..Length(Nom_fichier) = ".net"

   -- Tests :
   -- Entrée : ./pagerank -I -A exemple.txt;           Sortie : Missing_Arguments_Value_Error
   -- Entrée : ./pagerank -I b -A a exemple2.txt;      Sortie : Invalid_Type_Arguments_Error
   -- Entrée : ./pagerank -test exemple.txt;           Sortie : Invalid_Option_Error
   -- Entrée : ./pagerank;                             Sortie : None_Argument_Error
   -- Entrée : ./pagerank;                             Sortie : File_Absent_Error
   -- Entrée : ./pagerank -I 120 7 exemple.txt;        Sortie : Too_Many_Argument_Error
   -- Entrée : ./pagerank 0 2 exemple8.txt;            Sortie : Missing_Options_Error
   -- Entrée : ./pagerank -I 120 -A 0.9 exemple.txt;   Sortie : alpha = 0.9 ; iteration = 120; Nom_fichier = exemple.txt

   -- Exceptions : voir ci-dessus
   procedure Recuperer_valeurs_option(alpha : out T_alpha; iteration : out Integer; naive : out Boolean; Nom_fichier : out Unbounded_String );

end Recuperation_Argument;
