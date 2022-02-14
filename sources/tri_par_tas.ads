--Ce module met en place les outils qui vont nous permettre de trier la matrice poids par valeur décroissante

with Google_Naive;

generic

   nb_ligne : Integer;
   nb_col : Integer;             -- nombre de colonne dans le tas (qui sera représenté par un tableau et non un ABR)

   type T_Element is digits <>;   -- type associé au poids de chaque noeud

   with package P_Google_Naive is new Google_Naive(nombre_max_ligne=>nb_ligne, nombre_max_colonne => nb_col, T_Element=> T_Element);

package Tri_par_tas is

   --! ces types ne sont pas privés pour simplifier l'utilisation de ce module, nous avons confiance dans les appelants (qui sont nous-mêmes)

   type T_couple is
      record
         indice : Integer;          --{indice >=1 and indice <= matrice.nb_colonne}
         weight : T_Element;
      end record;

   subtype List_Index is natural range 1 .. nb_col;

   type T_vecteur is array (List_Index) of T_couple;

   -- Le module renvoit un type "vecteur" ou chaque coefficient du vecteur vaut (indice_origine : poids)
   type T_vecteur_couple is
      record
         vecteur : T_vecteur;
         taille : Integer;
      end record;

   Empty_tas_error : exception;
   Full_tas_error : exception;

   -- Nom : Afficher
   -- Semantique : Afficher un tas, procedure utile pour débuguer et les tests
   -- Paramètre(s) :
   -- tas : in  T_vecteur_couple;                      -- tas que l'on cherche à trier
   -- Pre : True
   -- Post : True
   -- Tests : Aucun
   -- Exception : Aucune
   procedure Afficher (tas : in T_vecteur_couple);

   -- Nom : Initialiser
   -- Semantique : Initialiseer un vecteur poids ou les coefficients valent (indice : poids)
   -- Paramètre(s) :
   -- vecteur_ligne : in vecteur_simple.T_Google_Naive;                       -- vecteur à trier
   -- poids : out T_vecteur_couple;                                            -- vecteur avec des couples (indice : poids)
   -- Pre : True
   -- Post : chaque coefficient.weight de poids correspond au coefficient de vecteur_ligne et chaque cofficient.indice de poids = indice

   -- Tests : Aucun
   -- Exception : Aucune
   procedure Initialiser_poids(vecteur_ligne : in P_Google_Naive.T_Google_Naive; poids: out T_vecteur_couple);


   -- Nom : Tri_tas
   -- Semantique : Trier la matrice poids par ordre décroissant des poids
   -- ATTENTION CE TRI EST INSTABLE MAIS CELA  NOUS SUFFIT POUR LE PAGERANK
   -- Paramètre(s) :
   -- tas : in out T_vecteur_couple;                       -- tas que l'on cherche à trier
   -- Pre : True
   -- Post : Le tableau est trié (condition complexe)

   -- Tests :
   -- Entrée : tas vide [] ;     Sortie : tas vide []
   -- Entrée : [( 0 : 7.32113E+04, )( 1 : 2.24492E+04, )( 2 : 7.86805E+04, )]
   -- Sortie : [( 2 : 7.86805E+04, )( 1 : 2.24492E+04, )( 0 : 7.32113E+04, )]

   -- Exception : Aucune
   procedure Tri_tas (poids : in out T_vecteur_couple);



end Tri_par_tas;
