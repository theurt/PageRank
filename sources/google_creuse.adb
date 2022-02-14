with Ada.Unchecked_Deallocation;
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;


package body google_creuse is

   -- Permet de libérer des pointeurs
   procedure Free is
     new Ada.Unchecked_Deallocation (T_Cellule, T_Vecteur_Creux);
   

   procedure Initialiser (matrice : out T_Google_Creuse; dimensions_ligne : in Integer; dimensions_colonne : in Integer) is 

   begin 
      matrice.nb_ligne := dimensions_ligne; 
      matrice.nb_colonne := dimensions_colonne;
      for i in 1..matrice.nb_ligne loop 
	 matrice.contenu(i) := Null;
      end loop; 
   end Initialiser;


   -- Nom : Detruire_pointeur
   -- Semantique : Libérer la mémoire alloué à une ligne d'une matrice creuse
   -- Paramètre(s) :
   -- pointeur : in out Vecteur_Creux;     -- contenu de la matrice à libérer
   -- Pre : True
   -- Post : matrice associée, Est_vide(matrice)

   -- Tests : 
   -- Entrée : Matrice_A = [[1,0],[0,1]] Sortie : Rien
   -- Exception : Aucune
   procedure Detruire_pointeur ( pointeur : in out T_Vecteur_Creux) is 
   begin 
      if pointeur = Null then
	 Null;

      else
	 -- Supprimer toute la ligne 
	 Detruire_pointeur(pointeur.all.colonne_suivante);
	 Free(pointeur);
      end if; 
   end Detruire_pointeur;


   procedure Detruire( matrice : in out T_Google_Creuse) is

   begin 
      -- Supprimer ligne par ligne
      for i in 1..matrice.nb_ligne loop 
	 Detruire_pointeur(matrice.contenu(i));
      end loop; 
      matrice.nb_ligne := 0; 
      matrice.nb_colonne := 0;
   end Detruire;


   function Est_Vide (Matrice : in T_Google_Creuse) return Boolean is

   begin 
      return Matrice.nb_ligne = 0 and Matrice.nb_colonne = 0  ; 
		
   End Est_Vide;



   procedure Dimension(Matrice : in T_Google_Creuse; ligne : out Integer; colonne : out Integer) is

   begin 
      ligne := Matrice.nb_ligne; 
      colonne := matrice.nb_colonne;
   End Dimension;

   function Get_coefficient (Matrice : in T_Google_Creuse; ligne : in Integer; colonne : in Integer) return T_Element is

      curseur : T_Vecteur_Creux;           -- pointeur servant à parcourir les lignes 


   begin 
      -- Traiter le cas ou les indices donnés sont trop grands
      if ligne > Matrice.nb_ligne or colonne > Matrice.nb_colonne then 
	 raise Invalid_Indices_Error;

      else    -- fonctionnement normal 

	 -- Chercher la bonne ligne 
	 if Matrice.contenu(ligne)= Null then      -- coefficient absent
	    return T_Element(0); 
		
	 else 
	    -- Chercher la bonne colonne 
	    curseur := Matrice.contenu(ligne); 
	    while curseur /= null and then curseur.all.indice_colonne /= colonne loop 
	       curseur := curseur.all.colonne_suivante; 
	    end loop; 

	    if curseur = Null then         -- coefficient absent
	       return T_Element(0);
	    else 
	       return curseur.all.valeur; 
	    end if; 
	 end if; 
      end if;

		 
   end Get_coefficient;

	
   -- Nom : Modifier_ligne
   -- Semantique : Enregistrer un coefficient dans un vecteur creux ligne 
   -- Paramètre(s) :
   -- V : in out T_Vecteur_Creux;     -- vecteur ligne � consid�rer
   -- Indice_colonne : in INteger;    -- indice de la colonne du coefficient � rajouter/modifier
   -- Valeur : in Integer;            -- valeur du coefficient
   -- Pre : True
   -- Post : Get_coefficient_ligne(V,Indice_colonne) = Valeur

   -- Tests : 
   -- Entrée :compliqu� � formaliser 
   -- Exception : Aucune
   procedure Modifier_ligne (V : in out T_Vecteur_Creux ;
			     Indice_colonne : in Integer;
			     Valeur : in T_Element ) is

      memoire : T_Vecteur_Creux;

   begin
      -- Traiter le cas de base de la récursivité : ligne vide 
      if V = Null then

	 if valeur /=0.0 then
	    -- Ajouter la valeur 
	    V := new T_Cellule;
	    V.All.Indice_colonne := Indice_colonne;
	    V.all.Valeur := Valeur; 
	    V.all.colonne_suivante := Null;
						
	    --Modifier par 0 revient à ne rien faire dans ce cas là
	 else
	    Null;
	 end if;
      else
	 --Traiter le cas ou l'indice est trouvé
	 if V.all.indice_colonne = Indice_colonne then
	    if Valeur /= T_Element(0) then
	       V.all.valeur := valeur;
	    else
	       V := V.all.colonne_suivante;
	    end if;

	    -- Traiter le cas de base ou l'élément est forcément absent
	 elsif V.all.indice_colonne > Indice_colonne then
	    if valeur = T_Element(0) then
	       Null;
	    else

	       memoire := V;
	       V:= new T_cellule;
	       V.all.valeur := Valeur;
	       V.all.indice_colonne := Indice_colonne;
	       V.all.colonne_suivante := memoire;
	    end if;
	    --Traiter la récursivité : je n'ai pas encore trouvé l'indice donc je continue
	 else
	    Modifier_ligne(V.all.colonne_suivante,Indice_colonne,Valeur);
	 end if;
      end if;
   end Modifier_ligne;

   procedure Enregistrer_coefficient (Matrice : in out T_Google_Creuse; ligne : in Integer; colonne : in Integer; coefficient : in T_Element) is
		
   begin
      if colonne > Matrice.nb_colonne or ligne > Matrice.nb_ligne then    -- indices hors champs
	 raise Invalid_indices_Error;
      else 

	 if Matrice.contenu(ligne) = Null then                   -- ligne remplie de 0 
	    if coefficient = T_Element(0) then 
	       Null; 
	    else 
	       -- Rajouter la nouvelle ligne
	       Matrice.contenu(ligne) := new T_Cellule; 
	       Matrice.contenu(ligne).valeur := coefficient;
	       Matrice.contenu(ligne).indice_colonne := colonne; 
	       Matrice.contenu(ligne).colonne_suivante := Null; 
	    end if; 
	 else      -- la ligne compotr des coefficients non nuls => on recherche la colonne 
	    Modifier_ligne(V => Matrice.contenu(ligne),Indice_colonne => colonne,Valeur => coefficient );
	 end if; 
      end if; 
   end Enregistrer_coefficient;



   procedure Affecter (Matrice_A : in out T_Google_Creuse; Matrice_B : in T_Google_Creuse) is
      coefficient : T_Element;       -- coefficient B(i,j)
   begin 

      if Matrice_B.nb_ligne /= Matrice_A.nb_ligne or Matrice_B.nb_colonne /= Matrice_A.nb_colonne then      -- dimensions incompatibles
	 raise Dimensions_incompatibles_Error; 

      else 
	 if Matrice_B.nb_ligne = 0 and Matrice_B.nb_colonne = 0 then   -- si B est vide, affecter B � A revient � detruire A
	    Detruire(Matrice_A);
	 else 
	    -- Affecter chacun des coefficients de B à A
	    for i in 1..Matrice_B.nb_ligne loop 
	       for j in 1..Matrice_B.nb_colonne loop
		  coefficient := Get_coefficient(Matrice_B,i,j);
		  Enregistrer_coefficient(Matrice_A,i,j,coefficient);
	       end loop; 
	    end loop;
	 end if; 
      end if; 

   end Affecter;


   function Somme (Matrice_A : in T_Google_Creuse; Matrice_B : in T_Google_Creuse) return T_Google_Creuse is


      -- Nom : Additioner_ligne 
      -- Semantique : Ajouter deux vecteurs lignes creux
      -- Paramètre(s) :
      -- V1 : in out Vecteur_Creux;     -- ligne matrice 1
      -- V2 : in out Vecteur_Creux;     -- ligne matrice 2
      -- Pre : True
      -- Post : Trop complexe pour être exprimée

      -- Tests : 
      -- Entrée : Matrice_A = [1,0] , contenu_2 = [2,0] ; Sortie : [3,0]
      -- Exception : Aucune
      procedure Additionner_ligne (V1 : in out T_Vecteur_Creux; V2 : in T_Vecteur_Creux) is


      begin

	 if V2 = Null and V1 = Null then      -- vecteurs vide
	    Null;

	 elsif V2 = Null and V1 /= NUll then  
	    Null;

	 elsif V2 /= Null and V1 = Null then
	    -- Ajouter tout le contenu de V2 à V1 
	    Modifier_ligne(V1,V2.all.indice_colonne,V2.all.valeur);
	    Additionner_ligne(V1,V2.all.colonne_suivante);
	 else
	    if V1.all.indice_colonne < V2.all.indice_colonne then      -- la ligne est absente de V2 => pas grave car on somme sur V1
	       Additionner_ligne(V1.all.colonne_suivante,V2);

	    elsif V1.all.indice_colonne > V2.all.indice_colonne then    -- la ligne est absente de V1 => on l'ajoute
	       Additionner_ligne(V1,V2.all.colonne_suivante);
	       Modifier_ligne(V1,V2.all.indice_colonne,V2.all.valeur);

	    else  -- les deux lignes sont présentes => on les ajoute
	       Modifier_ligne(V1,V1.all.indice_colonne,(V1.all.valeur+V2.all.valeur));
	       Additionner_ligne(V1.all.colonne_suivante,V2.all.colonne_suivante);

	    end if;

	 end if;

      end Additionner_ligne;

      resultat : T_Google_Creuse;        -- stocke la valeur de la somme � retourner
   begin 
      if Matrice_A.nb_ligne /= Matrice_B.nb_ligne or Matrice_A.nb_colonne /= Matrice_B.nb_colonne then      -- Dimensions incompatibles 
	 raise Dimensions_incompatibles_Error; 

      else 
	 Resultat := Matrice_A;
	 -- Ajouter ligne par ligne
	 for i in 1..Matrice_A.nb_ligne loop 
	    Additionner_ligne(V1 => Resultat.contenu(i),V2 => Matrice_B.contenu(i));
	 end loop; 
	 return Resultat;
      end if; 
   end Somme;

   procedure Produit_scalaire_matrice(Matrice : in out T_Google_Creuse; scalaire : in T_Element) is

      coefficient : T_Element;        -- Matrice(i,j)
   begin 

      for i in 1..Matrice.nb_ligne loop 
	 for j in 1..Matrice.nb_colonne loop 
	    coefficient := Get_coefficient(Matrice,i,j); 
	    Enregistrer_coefficient(Matrice,i,j,coefficient * scalaire); 
	 end loop; 
      end loop; 
   End Produit_scalaire_matrice;


   function Egalite (Matrice_A : in T_Google_Creuse; Matrice_B : in T_Google_Creuse) return Boolean is 

      ligne : Integer;
      colonne : Integer;
      condition : Boolean;
   begin

      --Traiter les cas ou les vecteurs rentrés sont Nulls
      if Matrice_A.nb_ligne /= Matrice_B.nb_ligne or Matrice_A.nb_colonne /= Matrice_B.nb_colonne then
	 return False;

      else
	 ligne := 1; 
	 condition := True; 
	 -- V�rifier l'�galit� des A(i,j) et B(i,j)
	 while ligne < Matrice_A.nb_ligne and condition loop 
	    colonne := 1; 

	    while colonne < Matrice_A.nb_colonne and condition loop
	       if Get_coefficient(Matrice_A,ligne,colonne)= Get_coefficient(Matrice_B,ligne,colonne) then 
		  colonne := colonne +1;  
	       else             -- A(i,j) != B(i,j) => on stoppe
		  condition := False; 
	       end if; 
	    end loop;
	    ligne := ligne +1; 
	 end loop ;
	 return condition; 
      end if;
   end Egalite;


   -- NB : procédure utile pour le débugageg donc volontairement peu commentée/raffinée
   procedure Affichage (Matrice : in T_Google_Creuse) is

      curseur_colonne : T_Vecteur_Creux;
      tmp_2 : T_Vecteur_Creux;
      compteur : Integer;
   begin 

      -- Afficher matrice vide
      if Matrice.nb_colonne = 0 and Matrice.nb_ligne = 0  then
	 Put("matrice creuse de taille : "); 
	 Put(Matrice.nb_ligne,0); 
	 Put(Matrice.nb_colonne,1);
	 Put("[]");
      else


	 compteur := 1; 

	 -- Afficher ligne par ligne la matrice
	 while compteur /= Matrice.nb_ligne +1 loop 

	    curseur_colonne := Matrice.contenu(compteur);
				 

	    if curseur_colonne /= Null then 
					
	       -- Afficher les éléments nuls avant le premier coefficient de chaque ligne
	       for i in 1..curseur_colonne.all.indice_colonne-1 loop 
		  Afficher(T_Element(0));
		  Put(',');
		  Put(' ');
	       end loop; 

	       -- Afficher le premier coefficient non nul
	       Put('[');
	       Afficher(curseur_colonne.all.Valeur);
	       Put(',');
	       Put(' ');
	       tmp_2 := curseur_colonne;

	       -- Afficher les 0 en fin de lignes s'il n'y a qu'un coefficient
	       if curseur_colonne.all.colonne_suivante = Null then 
		  for i in curseur_colonne.all.indice_colonne + 1..matrice.nb_colonne loop 
		     Afficher(T_Element(0));
		     Put(',');
		     Put(' ');
		  end loop; 
	       end if;


	       curseur_colonne := curseur_colonne.all.colonne_suivante; 
	       while curseur_colonne /= Null loop 
					
		  -- Boucher les creux par des 0 
		  for i in tmp_2.all.indice_colonne +1..curseur_colonne.all.indice_colonne-1 loop 
		     Afficher(T_Element(0));
							
		  end loop; 
		
		  -- Afficher le coefficient non nul suivant
		  Afficher(curseur_colonne.all.Valeur);
		  Put(',');
		  Put(' ');
		  tmp_2 := curseur_colonne; 
					
		  -- Afficher les 0 en fin de lignes 
		  if curseur_colonne.all.colonne_suivante = Null then 
		     for i in curseur_colonne.all.indice_colonne + 1..matrice.nb_colonne loop 
			Afficher(T_Element(0));
			Put(',');
			Put(' ');
		     end loop; 
		  end if;
		  curseur_colonne := curseur_colonne.all.colonne_suivante; 
				
	  
					
	       end loop;
	       Put(']');
				
					 
	       New_line;

	       -- Afficher les lignes entièrement nulle
	    else 
	       Put('[');
	       for i in 1..Matrice.nb_colonne loop 
		  Afficher(T_Element(0));
		  Put(',');
		  Put(' '); 
	       end loop; 
	       Put(']');
	       New_line;
	    end if; 
	    compteur := compteur +1;
	 end loop; 
	       
      end if;
   end Affichage;

end google_creuse;
