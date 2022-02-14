-- Spécification du module Conversion_Type qui permet de convertir des chaines de caractère en Integer ou réel

with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

generic

   type T_Element is digits <>;

package Conversion_Type is

   Bad_Type_Conversion_Error : exception;

   -- Nom : To_Integer
   -- Semantique : Convertir une chaine en integer
   -- Paramètre(s) :
   -- Chaine : in Unbounded_String;     -- chaine à convertir
   -- Type de retour : Integer
   -- Pre : True
   -- Post : To_Integer'Result - To_Integer'Result = 0

   -- Tests :
   -- Entrée : "2.1"                                Sortie : Bad_Type_Conversion_error
   -- Entrée : '2'                                  Sortie : 2

   -- Exceptions : Bad_Type_Conversion_error si l'utilisateur ne rentre pas un integer
   function To_Integer( chaine : in Unbounded_String) return Integer;

   -- Nom : To_reel
   -- Semantique : Convertir une chaine en réel
   -- Paramètre(s) :
   -- chaine : in Unbounded_String;            -- chaine à convertir
   -- Type de retour : T_Element;
   -- Pre : True
   -- Post : To_reel'Result-To_reel'Result = T_Element(0)

   -- Tests :
   -- Entrée : "2.1"                                Sortie : 2.1
   -- Entrée : "0.333"                              Sortie : 0.333

   -- Exceptions : Bad_Type_Conversion_error si l'utilisateur ne rentre pas un réel
   function To_reel( chaine : in Unbounded_String) return T_Element;


   -- Nom : Integer_or_reel
   -- Semantique : Selon la chaine rentrée, renvoit la conversion en réel ou entier
   -- de même qu'un indicateur précisant le type rentré
   -- Paramètre(s) :
   -- chaine : in Unbounded_String;     -- chaine de taille quelconque à convertir
   -- reel : out T_Element;             -- réel éventuelllement converti
   -- entier : out Integer;             -- entier éventuellement converti
   -- indicateur : out Character;       -- si l'indicateur est 'i' c'est un integer si c'est 'f' c'est un float qui commence par 0,... et si c'est 'o'
   --                                                                                                        c'est autre chose
   -- Pre : True
   -- Post : indicateur = 'f' or indicateur = 'i' or indicateur = 'o'

   -- Tests :
   -- Entrée : "2.1" ;                              Sortie : 'o'
   -- Entrée : "0.333" ;                            Sortie : 'f'
   -- Entrée : "120";                               Sortie : 'i'

   -- Exceptions : Aucune
   Procedure Integer_or_reel ( chaine : in Unbounded_String; reel : out T_Element;
                               entier : out Integer; indicateur : out Character);

end Conversion_Type;
