-- Ce module définit un type matrice creuse et les opérations associés. Une
-- matrice creuse est une matrice qui contient essentiellement des 0. Aussi pour
-- économiser l'espace de stockage, on ne stocke que les valeurs non nulles

generic

   type T_Element is digits <>;         -- type r�el des coefficients
   nb_max_ligne : Integer;              -- nombre fixe de lignes (nombre de colonne variable)

package google_creuse is

   type T_Google_Creuse is limited private;

   Dimensions_incompatibles_Error : exception;        -- opération entre matrice impossible due aux dimensions
   Invalid_indices_Error : exception;                 -- indice incorrectes

   -- Nom : Initialiser
   -- Semantique : Initialiser une matrice
   -- Paramètre(s) :
   -- Matrice : out T_Google_Creuse;          -- matrice à initialiser
   -- dimensions_colonne : out Integer;      -- nombre de colonnes de la matrice
   -- dimensions_ligne : out Integer;        -- nombre de lignes de la matrice
   -- Pre : True
   -- Post : dimensions_ligne = matrice.nb_ligne and dimensions_colonne = matrice.nb_colonne
   -- Tests : Aucun 
   -- Exception : Aucune
   procedure Initialiser (matrice : out T_Google_Creuse; dimensions_ligne : in Integer; dimensions_colonne : in Integer);

   -- Nom : Detruire
   -- Semantique : Libérer la mémoire occupée par la matrice
   -- Paramètre(s) :
   -- Matrice : in out T_Google_Creuse;     -- matrice à détruire
   -- Pre : True
   -- Post : Est_Vide(matrice);

   -- Exception : aucune
   procedure Detruire( matrice : in out T_Google_Creuse) ;


   -- Nom : Est_Vide
   -- Semantique : Est-ce que la matrice est vide ?
   -- Paramètre(s) :
   -- Matrice : out T_Google_Creuse;     -- matrice à initialiser
   -- Type de retour : Boolean
   -- Pre : True
   -- Post : True

   -- Tests :
   -- Entrée : matrice vide [[]] ; Sortie : True
   -- Entrée : [[0]]   ; Sortie : False
   -- Exception : Aucune
   function Est_Vide (Matrice : in T_Google_Creuse) return Boolean;


   -- Nom : Dimension
   -- Semantique : Renvoyer les dimensions d'une matrice
   -- Paramètre(s) :
   -- Matrice : in T_Google_Creuse;          -- matrice concern�e
   -- nb_ligne : out Integer;               -- nombre de lignes de la matrice
   -- nb_colonne : out Integer;             -- nombre de colonnes de la matrice
   -- Pre : True
   -- Post : ligne = Matrice.nb_ligne and colonne = Matrice.nb_colonne

   -- Tests :
   -- Entrée : Matrice = [[2,3],[4,1]] ; Sorties : nb_ligne = 2, nb_colonne = 2
   -- Entrée : Matrice = [[0]] ; Sorties : nb_ligne = 1, nb_colonne = 1
   -- Entrée : Matrice vide  ; Sorties : nb_ligne = 0, nb_colonne = 0
   -- Exception : Aucune
   procedure Dimension(Matrice : in T_Google_Creuse; ligne : out Integer; colonne : out Integer);


   -- Nom : Get_coefficient
   -- Semantique : Renvoyer le coefficient (ligne,colonne)
   -- Paramètre(s) :
   -- Matrice : in T_Google_Creuse;                   -- matrice initialiserconcern�e à
   -- ligne : in Integer;                            -- numéro de la ligne du coefficient
   -- colonne : in Integer;                          -- numéro de la colonne du coefficient
   -- Type de retour : T_Element
   -- Pre : True
   -- Post : Get_coefficient(Matrice,ligne,colonne) = Matrice(ligne,colonne)

   -- Tests :
   -- Entrée : Matrice = [[2,3],[4,1]] , ligne = 1 , colonne = 1 ; Sortie : 2
   -- Entrée : Matrice = [[0]] , ligne = 1 , colonne = 2  ; Sortie : Invalid_Indices_Error

   -- Exception : Invalid_Indices_Error
   function Get_coefficient (Matrice : in T_Google_Creuse; ligne : in Integer; colonne : in Integer) return T_Element;


   -- Nom : Enregistrer_coefficient
   -- Semantique : Affecter une valeur à un coefficient d'une matrice
   -- Paramètre(s) :
   -- Matrice : in out T_Google_Creuse;     -- matrice � changer
   -- ligne : in Integer;                  -- numéro de la ligne du coefficient
   -- colonne : in Integer;                -- numéro de la colonne du coefficient
   -- coefficient : in Integer;            -- valeur à affecter
   -- Type de retour : T_Element
   -- Pre : True
   -- Post : Get_coefficient(Matrice,ligne,colonne) = coefficient and les autres coefficients sont identiques

   -- Tests :
   -- Entrée : Matrice = [[2,3],[4,1]] , ligne = 1 , colonne = 1 , coefficient = 5 ; Sortie : [[5,3],[4,1]]
   -- Entrée : Matrice = [[0]] , ligne = 1 , colonne = 2  , coefficient = 6 ; Sortie : Invalid_Indices_Error

   -- Exception : Invalid_Indices_Error
   procedure Enregistrer_coefficient (Matrice : in out T_Google_Creuse; ligne : in Integer; colonne : in Integer; coefficient : in T_Element);


   -- Nom : Somme
   -- Semantique : Somme matricielle
   -- Paramètre(s) :
   -- Matrice_A : in  T_Google_Creuse;           -- premier terme
   -- Matrice_B : in  T_Google_Creuse;           -- deuxième terme
   -- Type de retour : T_Google_Creuse;
   -- Pre : True
   -- Post : les A(i,j)+B(i,j) sont égaux aux Somme'Result(i,j)

   -- Tests :
   -- Entrée : Matrice_A = [[2,3],[4,1]] , Matrice_B = [[1,2],[4,1]] ; Sortie : [[3,5],[8,2]]
   -- Entrée : Matrice_A = [[0]] , Matrice_B = [[1,2],[4,1]] ; Sortie : Dimensions_incompatible_Error

   -- Exception : Dimensions_incompatible_Error
   function Somme (Matrice_A : in T_Google_Creuse; Matrice_B : in T_Google_Creuse) return T_Google_Creuse;

   -- Nom : Produit_scalaire_matrice
   -- Semantique : Produit entre une matrice et un scalaire
   -- Paramètre(s) :
   -- Matrice : in out T_Google_Creuse;     -- matrice à multiplier
   -- Scalaire : in T_Element
   -- Pre : True
   -- Post : les Produit_scalaire_matrice'Result(i,j) = scalaire*Produit_scalaire_matrice'Before(i,j)

   -- Tests :
   -- Entrée : Matrice = [[1,0],[0,1]] , scalaire = 5 ; Sortie : [[5,0],[0,5]]
   -- Entrée : Matrice = matrice vide, scalaire = 1 ; Sortie : matrice vide


   -- Exception : Aucune
   procedure Produit_scalaire_matrice(Matrice : in out T_Google_Creuse; scalaire : in T_Element) ;


   -- Nom : Egalite
   -- Semantique : Vérifier l'égalité entre deux matrices
   -- Paramètre(s) :
   -- Matrice_A : in T_Google_Creuse;
   -- Matrice_B : in T_Google_Creuse;
   -- Pre : True
   -- Post : Matrice_A(i,j)=Matrice_B(i,j)

   -- Tests :
   -- Entrée : Matrice_A = [[1,0],[0,1]] , Matrice_B = [[1,0],[1,0]] ; Sortie : True
   -- Entrée : Matrice_A = [[1,2],[3,1]] , Matrice_B = [[1,2],[4,1]] ; Sortie : False
   -- Entrée : Matrice_A = [[0]] , Matrice_B = [[1,2],[4,1]] ; Sortie : Dimensions_incompatible_Error


   -- Exception : Dimensions_incompatible_Error
   function Egalite(Matrice_A : in T_Google_Creuse; Matrice_B : in T_Google_Creuse) return Boolean;


   -- Nom : Affecter
   -- Semantique : Affecter une matrice à une autre
   -- Paramètre(s) :
   -- Matrice_A : out T_Google_Creuse;     -- matrice à laquelle on affecte
   -- Matrice_B : in T_Google_Creuse;      -- matrice à affecter
   -- Pre : True
   -- Post : Egalite(Matrice_A'After,Matrice_B)

   -- Tests :
   -- Entrée : Matrice_A = [[1,0],[0,1]] , Matrice_B = [[1,2],[4,1]] ; Sortie : [[1,2],[4,1]]
   -- Entrée : Matrice_A = [[1,2],[3,1]] , Matrice_B = [[1,2],[4,1]] ; Sortie : [[9,4],[7,7]]
   -- Entrée : Matrice_A = [[0]] , Matrice_B = [[1,2],[4,1]] ; Sortie : Dimensions_incompatible_Error


   -- Exception : Dimensions_incompatible_Error
   procedure Affecter (Matrice_A : in out T_Google_Creuse; Matrice_B : in T_Google_Creuse) ;
   generic
      with procedure Afficher (Un_Element: in T_Element);

      -- Nom : Affichage
      -- Semantique : Afficher une matrice
      -- Paramètre(s) :
      -- Matrice_A : in T_Google_Creuse;     -- matrice à afficher
      -- Pre : True
      -- Post : True

      -- Tests : avec Afficher sur des entiers par exemple
      -- Entrée : Matrice_A = [[1,0],[0,1]] Sortie : [[1,0],[0,1]]
      -- Exceptions : peut �tre lev�e par Afficher
   procedure Affichage (Matrice : in T_Google_Creuse);


private

   type T_Cellule;

   type T_Vecteur_Creux is access T_Cellule;            -- pointeur sur cellule
	
   type T_Cellule is
      record
	 indice_colonne : Integer;
	 valeur : T_Element;
	 colonne_suivante : T_Vecteur_Creux;
	 -- Invariant :
	 --   Indice >= 1;
	 --   colonne_suivante = Null or else Suivant.all.Indice > Indice;
	 --   	-- les cellules sont stockés dans l'ordre croissant des indices des colonnes
      end record;

   type matrice_creuse is array (1..nb_max_ligne) of T_Vecteur_Creux;        -- matrice creuse = Tableau de vecteurs creux

   type T_Google_Creuse is 
      record 
	 contenu : matrice_creuse ; 
	 nb_ligne : Integer;          --{ nb_ligne >= 0 and nb_ligne <= nb_max_ligne}
	 nb_colonne : Integer;
      end record; 
end google_creuse;
