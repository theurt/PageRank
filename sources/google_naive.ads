-- Spécification du module Google_Naive définissant le type matrice pleine et ses opérations associées

generic

   nombre_max_ligne : Integer;    -- Nombre maximal de ligne pour une matrice
   nombre_max_colonne : Integer;  -- Nombre maximal de colonne pour une matrice

   type T_Element is digits <>;   -- Type des réels composants de la matrice

package Google_Naive is

   type T_Google_Naive is limited private;

   Dimensions_incompatibles_Error : exception;        -- opération entre matrice impossible due aux dimensiosn
   Invalid_indices_Error : exception;                 -- indice incorrects

   -- Nom : Initialiser
   -- Semantique : Initialiser une matrice
   -- Paramètre(s) :
   -- Matrice : out T_Google_Naive;          -- matrice à initialiser
   -- dimensions_colonne : out Integer;      -- nombre de colonnes de la matrice
   -- dimensions_ligne : out Integer;        -- nombre de lignes de la matrice
   -- Pre : True
   -- Post : dimensions_ligne = matrice.nb_ligne and dimensions_colonne = matrice.nb_colonne
   -- Tests :
   -- Entrée : dimensions_ligne = 2 ,  dimensions_colonne = 2  ; Sortie : [[,],[,]]
   -- Exceptions : Aucune
   procedure Initialiser (matrice : out T_Google_Naive; dimensions_ligne : in Integer; dimensions_colonne : in Integer);


   -- Nom : Est_Vide
   -- Semantique : Est-ce que la matrice est vide ?
   -- Paramètre(s) :
   -- Matrice : out T_Google_Naive;     -- matrice à vérifier
   -- Type de retour : Boolean
   -- Pre : True
   -- Post : True

   -- Tests :
   -- Entrée : matrice vide [[]] ; Sortie : True
   -- Entrée : [[0]]   ; Sortie : False
   -- Exceptions : Aucune
   function Est_Vide (Matrice : in T_Google_Naive) return Boolean;

   -- Nom : Dimension
   -- Semantique : Renvoyer les dimensions d'une matrice
   -- Paramètre(s) :
   -- Matrice : in T_Google_Naive;          -- matrice concern�e
   -- nb_ligne : out Integer;               -- nombre de lignes de la matrice
   -- nb_colonne : out Integer;             -- nombre de la colonnes de la matrice
   -- Pre : True
   -- Post : ligne = Matrice.nb_ligne and colonne = Matrice.nb_colonne

   -- Tests :
   -- Entrée : Matrice = [[2,3],[4,1]] ; Sorties : nb_ligne = 2, nb_colonne = 2
   -- Entrée : Matrice = [[0]] ; Sorties : nb_ligne = 1, nb_colonne = 1
   -- Entrée : Matrice vide  ; Sorties : nb_ligne = 0, nb_colonne = 0
   -- Exception : Aucune
   procedure Dimension(Matrice : in T_Google_Naive; ligne : out Integer; colonne : out Integer);


   -- Nom : Get_coefficient
   -- Semantique : Renvoyer le coefficient (ligne,colonne) de la matrice
   -- Paramètre(s) :
   -- Matrice : in T_Google_Naive;                   -- matrice concern�e
   -- ligne : in Integer;                            -- numéro de la ligne du coefficient
   -- colonne : in Integer;                          -- numéro de la colonne du coefficient
   -- Type de retour : T_Element
   -- Pre : True
   -- Post : Get_coefficient(Matrice,ligne,colonne) = Matrice(ligne,colonne)

   -- Tests :
   -- Entrée : Matrice = [[2,3],[4,1]] , ligne = 1 , colonne = 1 ; Sortie : 2
   -- Entrée : Matrice = [[0]] , ligne = 1 , colonne = 2  ; Sortie : Invalid_Indices_Error

   -- Exception : Invalid_Indices_Error
   function Get_coefficient (Matrice : in T_Google_Naive; ligne : in Integer; colonne : in Integer) return T_Element;


   -- Nom : Enregistrer_coefficient
   -- Semantique : Affecter une valeur à un coefficient d'une matrice
   -- Paramètre(s) :
   -- Matrice : in out T_Google_Naive;     -- matrice
   -- ligne : in Integer;                  -- numéro de la ligne du coefficient
   -- colonne : in Integer;                -- numéro de la colonne du coefficient
   -- coefficient : in Integer;            -- valeur à affecter
   -- Type de retour : T_Element
   -- Pre : True
   -- Post : Get_coefficient(Matrice,ligne,colonne) = coefficient and "les autres coefficients sont identiques"

   -- Tests :
   -- Entrée : Matrice = [[2,3],[4,1]] , ligne = 1 , colonne = 1 , coefficient = 5 ; Sortie : [[5,3],[4,1]]
   -- Entrée : Matrice = [[0]] , ligne = 1 , colonne = 2  , coefficient = 6 ; Sortie : Invalid_Indices_Error

   -- Exception : Invalid_Indices_Error
   procedure Enregistrer_coefficient (Matrice : in out T_Google_Naive; ligne : in Integer; colonne : in Integer; coefficient : in T_Element);

   -- Nom : Somme
   -- Semantique : Somme matricielle
   -- Paramètre(s) :
   -- Matrice_A : in  T_Google_Naive;           -- premier terme
   -- Matrice_B : in  T_Google_Naive;           -- deuxième terme
   -- Type de retour : T_Google_Naive;
   -- Pre : True
   -- Post : les A(i,j)+B(i,j) sont égaux aux Somme'Result(i,j)

   -- Tests :
   -- Entrée : Matrice_A = [[2,3],[4,1]] , Matrice_B = [[1,2],[4,1]] ; Sortie : [[3,5],[8,2]]
   -- Entrée : Matrice_A = [[0]] , Matrice_B = [[1,2],[4,1]] ; Sortie : Dimensions_incompatible_Error

   -- Exception : Dimensions_incompatible_Error
   function Somme (Matrice_A : in T_Google_Naive; Matrice_B : in T_Google_Naive) return T_Google_Naive;


   -- Nom : Produit_matrices
   -- Semantique : Produit matriciel
   -- Paramètre(s) :
   -- Matrice_A : in T_Google_Naive;         -- premier terme
   -- Matrice_B : in T_Google_Naive;         -- deuxième terme
   -- Type de retour : T_Google_Naive
   -- Pre : True
   -- Post : les Produit_matrices'Result(i,j) sont égaux à la somme sur k des A(i,k)*B(k,j)

   -- Tests :
   -- Entrée : Matrice_A = [[1,0],[0,1]] , Matrice_B = [[1,2],[4,1]] ; Sortie : [[1,2],[4,1]]
   -- Entrée : Matrice_A = [[1,2],[3,1]] , Matrice_B = [[1,2],[4,1]] ; Sortie : [[9,4],[7,7]]
   -- Entrée : Matrice_A = [[0]] , Matrice_B = [[1,2],[4,1]] ; Sortie : Dimensions_incompatible_Error


   -- Exception : Dimensions_incompatible_Error
   function Produit_matrices (Matrice_A : in T_Google_Naive; Matrice_B : in T_Google_Naive) return T_Google_Naive;


   -- Nom : Produit_scalaire_matrice
   -- Semantique : Produit entre une matrice et un scalaire
   -- Paramètre(s) :
   -- Matrice : in out T_Google_Naive;     -- matrice à multiplier
   -- Scalaire : in T_Element;             -- scalaire concern�
   -- Pre : True
   -- Post : les Produit_scalaire_matrice'Result(i,j) = scalaire*Produit_scalaire_matrice'Precedent(i,j)

   -- Tests :
   -- Entrée : Matrice = [[1,0],[0,1]] , scalaire = 5 ; Sortie : [[5,0],[0,5]]
   -- Entrée : Matrice = matrice vide, scalaire = 1 ; Sortie : matrice vide


   -- Exception : Aucune
   procedure Produit_scalaire_matrice(Matrice : in out T_Google_Naive; scalaire : in T_Element) ;


   -- Nom : Egalite
   -- Semantique : Vérifier l'égalité entre deux matrices
   -- Paramètre(s) :
   -- Matrice_A : in T_Google_Naive;          -- premier terme
   -- Matrice_B : in T_Google_Naive;          -- deuxi�me terme
   -- Pre : True
   -- Post : Matrice_A(i,j)= Matrice_B(i,j)

   -- Tests :
   -- Entrée : Matrice_A = [[1,0],[0,1]] , Matrice_B = [[1,0],[1,0]] ; Sortie : True
   -- Entrée : Matrice_A = [[1,2],[3,1]] , Matrice_B = [[1,2],[4,1]] ; Sortie : False
   -- Entrée : Matrice_A = [[0]] , Matrice_B = [[1,2],[4,1]] ; Sortie : Dimensions_incompatible_Error


   -- Exception : Dimensions_incompatible_Error
   function Egalite(Matrice_A : in T_Google_Naive; Matrice_B : in T_Google_Naive) return Boolean;


   -- Nom : Affecter
   -- Semantique : Affecter une matrice à une autre
   -- Paramètre(s) :
   -- Matrice_A : out T_Google_Naive;     -- matrice à laquelle on affecte
   -- Matrice_B : in T_Google_Naive;      -- matrice à affecter
   -- Pre : True
   -- Post : Egalite(Matrice_A'After,Matrice_B)

   -- Tests :
   -- Entrée : Matrice_A = [[1,0],[0,1]] , Matrice_B = [[1,2],[4,1]] ; Sortie : [[1,2],[4,1]]
   -- Entrée : Matrice_A = [[1,2],[3,1]] , Matrice_B = [[1,2],[4,1]] ; Sortie : [[9,4],[7,7]]
   -- Entrée : Matrice_A = [[0]] , Matrice_B = [[1,2],[4,1]] ; Sortie : Dimensions_incompatible_Error


   -- Exception : Dimensions_incompatible_Error
   procedure Affecter (Matrice_A : in out T_Google_Naive; Matrice_B : in T_Google_Naive);

   generic
      with procedure Afficher (Un_Element: in T_Element);

      -- Nom : Affichage
      -- Semantique : Afficher une matrice
      -- Paramètre(s) :
      -- Matrice_A : in T_Google_Naive;     -- matrice à afficher
      -- Pre : True
      -- Post : True

      -- Tests : avec Afficher sur des entiers par exemple
      -- Entrée : Matrice_A = [[1,0],[0,1]] Sortie : [[1,0],[0,1]]
      -- Exceptions : peut �tre lev�e par affichage
   procedure Affichage (Matrice : in T_Google_Naive);


private

   type T_Tableau is array (1..nombre_max_ligne,1..nombre_max_colonne) of T_Element;        -- matrice = tableau de tableau en naif

   type T_Google_Naive is
      record
	 tableau : T_Tableau;      -- les Ã©lÃ©ments de la matrice
	 nb_ligne : Integer;        -- Nombre effectif de ligne dans la matrice
	 nb_colonne : Integer;      -- Nombre effectif de colonne dans la matrice
      end record;

end Google_Naive;
