with Ada.Unchecked_Deallocation;
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;


package body google_creuse_lente is

	-- Permet de libérer des pointeurs
	procedure Free is
	  new Ada.Unchecked_Deallocation (T_Cellule, T_Vecteur_Creux);
   

	procedure Initialiser (matrice : out T_Google_Creuse; dimensions_ligne : in Integer; dimensions_colonne : in Integer) is 

	begin 
		matrice.nb_ligne := dimensions_ligne; 
		matrice.nb_colonne := dimensions_colonne; 
		matrice.contenu := Null;
	end Initialiser;


	-- Nom : Detruire_pointeur
	-- Semantique : Libérer la mémoire alloué à un type T_Vecteuer_Creux et non T_Google_Creux ! 
	-- Paramètre(s) :
	-- pointeur : in out Vecteur_Creux;     -- contenu de la matrice à libérer
	-- Pre : True
	-- Post : matrice associée Est_vide(matrice)

	-- Tests : 
	-- Entrée : Matrice_A = [[1,0],[0,1]] Sortie : Rien
	procedure Detruire_pointeur ( pointeur : in out T_Vecteur_Creux) is 
	begin 
		if pointeur = Null then
			Null;

		else
			-- Supprimer la toute la ligne 
			Detruire_pointeur(pointeur.all.ligne_suivante);
			Detruire_pointeur(pointeur.all.colonne_suivante);
			Free(pointeur);
		end if; 
	end Detruire_pointeur;


	procedure Detruire( matrice : in out T_Google_Creuse) is

	begin 
		Detruire_pointeur(matrice.contenu);
		matrice.nb_ligne := 0; 
		matrice.nb_colonne := 0; 

	end Detruire;


	function Est_Vide (Matrice : in T_Google_Creuse) return Boolean is

	begin 

		if matrice.nb_ligne = 0 and matrice.nb_colonne = 0  then 
			return True; 
		else 
			return False; 
		end if; 

	End Est_Vide;



	procedure Dimension(Matrice : in T_Google_Creuse; ligne : out Integer; colonne : out Integer) is

	begin 
		ligne := Matrice.nb_ligne; 
		colonne := matrice.nb_colonne;
	End Dimension;

	function Get_coefficient (Matrice : in T_Google_Creuse; ligne : in Integer; colonne : in Integer) return T_Element is

		curseur_ligne : T_Vecteur_Creux;           -- pointeur servant à parcourir les lignes 
		curseur_colonne : T_Vecteur_Creux;         -- pointeur servant à parcourir les colonnes
		tmp_1 : T_Vecteur_Creux;                     -- ponteur permettant la libération des deux précédents 
		tmp_2 : T_Vecteur_Creux;                     -- ponteur permettant la libération des deux précédents 
		resultat : T_Element;                      -- coefficient à renvoyer

	begin 
		-- Traiter le cas ou les indices donnés sont trop grands
		if ligne > Matrice.nb_ligne or colonne > Matrice.nb_colonne then 
			raise Invalid_Indices_Error;

		else    -- fonctionnement normal 

			curseur_ligne := Matrice.contenu; 

			-- Trouver la bonne ligne
			while curseur_ligne /= Null and then curseur_ligne.all.indice_ligne /= ligne loop 
				tmp_1 := curseur_ligne;
				curseur_ligne := curseur_ligne.all.ligne_suivante; 
			
			end loop; 

			-- La ligne ne comporte aucun coefficient non nul 
			if curseur_ligne = Null then 
				return T_Element(0); 
			else
				curseur_colonne := curseur_ligne; 
				-- Trouver la bonne colonne
				while curseur_colonne /= Null and then curseur_colonne.all.indice_colonne /= colonne loop 
					tmp_2 := curseur_colonne;
					curseur_colonne := curseur_colonne.all.colonne_suivante; 
				
				end loop; 

				if curseur_colonne = Null then 
					return T_Element(0);
				else 
					resultat := curseur_colonne.all.valeur;
					return resultat; 

				end if; 
			end if; 
		end if; 
	end Get_coefficient;

	

	procedure Enregistrer_coefficient (Matrice : in out T_Google_Creuse; ligne : in Integer; colonne : in Integer; coefficient : in T_Element) is
		
		-- Nom : Modifier 
		-- Semantique : Modifier ou créer un coefficient dans une matrice de type T_Vecteur_Creux
		-- Paramètre(s) :
		-- mat : in out Vecteur_Creux;     -- contenu de la matrice ou travailler
		-- ligne : in Integer;             -- numéro de la ligne
		-- colonne : in Integer;           -- numéro de la colonne
		-- coefficient : in T_Element;     -- coefficient à insérer
		-- Pre : True
		-- Post : Get_coefficient(mat,ligne,colonne) = coefficient

		-- Tests : 
		-- Entrée : Matrice_A = [[1,0],[0,1]], ligne = 1, colonne = 2, coefficient = 3 ; Sortie : [[1,3],[0,1]]
		-- Exception : Aucune
		procedure Modifier (mat: in out T_Vecteur_Creux; ligne : in Integer; colonne : in Integer; coefficient : in T_Element) is
			memoire : T_Vecteur_Creux;


		begin 

			-- Traiter le 1er cas de base de la récursivité : matrice vide 
			if mat = Null then

				memoire := mat; 
				-- Rajouter le coefficient 
				if coefficient /= 0.0 then
					mat:= new T_Cellule;
					mat.all.indice_ligne := ligne;
					mat.all.indice_colonne := colonne;
					mat.all.valeur := coefficient;
					mat.all.ligne_suivante := Null;
					mat.all.colonne_suivante := Null;
					mat.all.colonne_precedente := Null;                

					--Modifier par 0 revient à ne rien faire 
				else
					Null;
				end if;
			else
				-- Traiter le cas de base ou le coefficient devrait être sur une certaine ligne 
				if mat.all.indice_ligne = ligne then 

					if mat.all.indice_colonne = colonne then
					
						-- Remplacer le coefficient
						if coefficient /= 0.0 then          
							mat.all.valeur := coefficient;

						-- Supprimer le coefficient (car la mise à 0 le fait "disparaitre")
						else       
						
							memoire := mat; 
							if mat.all.colonne_suivante /= Null then 	       -- si le coefficient est au milieu de deux autres
								-- Extraire le coefficient de la matrice
								mat:= mat.all.colonne_suivante;
								mat.all.colonne_precedente := memoire.all.colonne_precedente; 
								mat.all.ligne_suivante := memoire.all.ligne_suivante;
							else 
								if mat.all.colonne_precedente = Null then       -- s'il n'y avait qu'un seul coefficient sur la ligne !
									-- Ignorer la ligne 
									mat:= mat.all.ligne_suivante;
								else                                            -- s'il est en bout de ligne
									-- Déréférencer le coefficient
									mat:= Null;  
								end if; 
							end if; 
						end if;

						-- Traiter le deuxième cas de base : le coefficient aurait du être à la colonne d'avant => il est nul 
					elsif mat.all.indice_colonne > colonne then 

						if coefficient = 0.0 then
							Null;
						else
							-- Insérer une nouvelle cellule
							memoire := mat;
							-- Mettre la nouvelle cellule à la place de l'ancienne
							mat:= new T_cellule;
							mat.all.valeur := coefficient;
							mat.all.indice_ligne := ligne;
							mat.all.indice_colonne := colonne;
							mat.all.ligne_suivante := memoire.all.ligne_suivante;
							mat.all.colonne_precedente := memoire.all.colonne_precedente;
							mat.all.colonne_suivante := memoire;  
					
							-- Déconnecter l'ancienne des lignes précédentes et suivantes
							memoire.all.colonne_precedente := mat; 

							-- Rattacher l'ancienne cellule à la nouvelle 
							memoire.all.ligne_suivante := Null;

						end if;
						-- Traiter le cas récursif sur les colonnes : continuer la recherche 
					else
						if mat.all.colonne_suivante = Null then 
	
							-- Mettre la nouvelle cellule après
							memoire:= new T_cellule;
							memoire.all.valeur := coefficient;
							memoire.all.indice_ligne := ligne;
							memoire.all.indice_colonne := colonne;
							memoire.all.ligne_suivante := Null;
							memoire.all.colonne_precedente := mat;
							memoire.all.colonne_suivante := Null; 
							mat.all.colonne_suivante := memoire; 
						else 
							Modifier(mat.all.colonne_suivante, ligne,colonne, coefficient);
						end if; 
					end if;
			
					-- Traiter un autre cas de base : il manque une ligne => on la rajoute
				elsif mat.all.indice_ligne > ligne then 
      
					if coefficient /= 0.0 then 

						memoire := mat;
						-- Insérer la nouvelle ligne
						mat:= new T_cellule;
						mat.all.valeur := coefficient;
						mat.all.indice_ligne := ligne;
						mat.all.indice_colonne := colonne;
						mat.all.colonne_suivante := Null;
						mat.all.colonne_precedente := Null;
			        
			        		        
						-- Rattacher aux ligne déjà existantes
						mat.all.ligne_suivante := memoire;
			        
					else           -- on veut insérer un 0 => aucun intérêt puisque la matrice est creuse
						Null; 
					end if; 
					-- Traiter l'autre cas récursif sur les lignes, on continue le parcours
				else 
					Modifier(mat.all.ligne_suivante,ligne,colonne, coefficient);
				end if;
			end if; 
		end Modifier;


	begin
		if colonne > Matrice.nb_colonne or ligne > Matrice.nb_ligne then 
			raise Invalid_indices_Error;
		else 
			Modifier(Matrice.contenu,ligne,colonne,coefficient);
		end if; 
		
	end Enregistrer_coefficient;



	procedure Affecter (Matrice_A : in out T_Google_Creuse; Matrice_B : in T_Google_Creuse) is
		coefficient : T_Element;
	begin 

		if Matrice_B.nb_ligne /= Matrice_A.nb_ligne or Matrice_B.nb_colonne /= Matrice_A.nb_colonne then      -- dimensions incompatibles
			raise Dimensions_incompatibles_Error; 

		else 
			if Matrice_B.nb_ligne = 0 and Matrice_B.nb_colonne =0 then   -- si B est vide => detruire A
				Detruire(Matrice_A);
			else 
				-- Affecter chacun des coefficients de B à A
				for i in 1..Matrice_B.nb_ligne loop 
					for j in 1..Matrice_B.nb_colonne loop
						coefficient := Get_coefficient(MAtrice_B,i,j);
						Enregistrer_coefficient(Matrice_A,i,j,coefficient);
					end loop; 
				end loop;
			end if; 
		end if; 

	end Affecter;


	function Somme (Matrice_A : in T_Google_Creuse; Matrice_B : in T_Google_Creuse) return T_Google_Creuse is

		-- Nom : Ajouter_contenu
		-- Semantique : Ajouter les contenus de deux matrices creuses (attention au type !)
		-- Paramètre(s) :
		-- contenu_1 : in out Vecteur_Creux;     -- contenu de la matrice_1
		-- contenu_2 : in out Vecteur_Creux;     -- contenu de la matrice_1
		-- Pre : True
		-- Post : Get_coefficient(contenu_1,ligne,colonne) = Get_coefficient( contenu_1'Before, ligne,colonne) + 
		-- Get_coefficient( contenu_2, ligne,colonne)

		-- Tests : 
		-- Entrée : Matrice_A = [[1,0],[0,1]], contenu_2 = [[2,0],[3,4]] ; Sortie : [[3,0],[3,5]]
		-- Exception : Aucune
		procedure Ajouter_contenu(contenu_1 : in out  T_Vecteur_Creux; contenu_2 : in T_Vecteur_Creux) is


			-- Nom : Additioner_ligne 
			-- Semantique : Ajouter les lignes de deux matrices selon un indice de ligne donnée
			-- Paramètre(s) :
			-- V1 : in out Vecteur_Creux;     -- ligne matrice 1
			-- V2 : in out Vecteur_Creux;     -- ligne matrice 2
			-- Pre : True
			-- Post : Trop complexe pour être exprimée

			-- Tests : 
			-- Entrée : Matrice_A = [1,0] , contenu_2 = [2,0] ; Sortie : [3,0]
			-- Exception : Aucune
			procedure Additionner_ligne (V1 : in out T_Vecteur_Creux; V2 : in T_Vecteur_Creux; numero_ligne : in Integer) is

				-- contrat identique à modifier hormis que le traitement ne se fait que sur une ligne 
				procedure Modifier_ligne (V : in out T_Vecteur_Creux ;
										Indice_ligne : in Integer ;
										Indice_colonne : in Integer;
										Valeur : in T_Element ) is

					memoire : T_Vecteur_Creux;

				begin
					-- Traiter le cas de base de la récursivité : ligne vide 
					if V = Null then

						if valeur /=0.0 then
							-- Ajouter la valeur 
							V := new T_Cellule;
							V.All.Indice_ligne := Indice_ligne;
							V.All.Indice_colonne := Indice_colonne;
							V.all.Valeur := Valeur;
							V.all.ligne_suivante := Null;
							V.all.colonne_precedente := Null;        
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
								memoire := V;
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
								V.all.indice_ligne := Indice_ligne;
								V.all.indice_colonne := Indice_colonne;
								V.all.colonne_suivante := memoire;
								V.all.colonne_precedente := memoire.all.colonne_precedente;
								memoire.all.colonne_precedente := V;
								V.all.ligne_suivante := memoire.all.ligne_suivante; 
								memoire.all.ligne_suivante := Null; 
							end if;
							--Traiter la récursivité : je n'ai pas encore trouvé l'indice donc je continue
						else
							Modifier_ligne(V.all.colonne_suivante, Indice_ligne,Indice_colonne,Valeur);
						end if;
					end if;
				end Modifier_ligne;
			begin

				if V2 = Null and V1 = Null then
					Null;

				elsif V2 = Null and V1 /= NUll then
					Null;

				elsif V2 /= Null and V1 = Null then
					-- Ajouter tout le contenu de V2 à V1 
					Modifier_ligne(V1,numero_ligne,V2.all.indice_colonne,V2.all.valeur);
					Additionner_ligne(V1,V2.all.colonne_suivante,numero_ligne);
				else
					if V1.all.indice_colonne < V2.all.indice_colonne then      -- la ligne est absente de V2
						Additionner_ligne(V1.all.colonne_suivante,V2,numero_ligne);

					elsif V1.all.indice_colonne > V2.all.indice_colonne then    -- la ligne est absente de V1 => on l'ajoute
						Additionner_ligne(V1,V2.all.colonne_suivante,numero_ligne);
						Modifier_ligne(V1,numero_ligne,V2.all.indice_colonne,V2.all.valeur);

					else  -- les deux lignes sont présentes => on les ajoute
						Modifier_ligne(V1,numero_ligne,V1.all.indice_colonne,(V1.all.valeur+V2.all.valeur));
						Additionner_ligne(V1.all.colonne_suivante,V2.all.colonne_suivante,numero_ligne);

					end if;

				end if;

			end Additionner_ligne;
		begin 

			-- Même principe qu'additioner_ligne mais sur les colonnes !
			if contenu_1 = Null and contenu_2 = Null then
				Null;

			elsif contenu_1 = Null and contenu_2 /= Null then
				contenu_1 := contenu_2; 

			elsif contenu_1 /= Null and contenu_2 = Null then
				Null;
			else
				if contenu_1.all.indice_ligne < contenu_2.all.indice_ligne then
					Ajouter_contenu(contenu_1.all.ligne_suivante,contenu_2);

				elsif contenu_1.all.indice_ligne > contenu_2.all.indice_ligne then
					Ajouter_contenu(contenu_1,contenu_2.all.ligne_suivante);
					-- Rajouter la ligne manquante !
					Additionner_ligne(contenu_1,contenu_2,contenu_2.all.indice_ligne);

				else
					-- Ajouter les deux colonnes
					Additionner_ligne(contenu_1,contenu_2,contenu_1.all.indice_ligne);
					Ajouter_contenu(contenu_1.all.ligne_suivante,contenu_2.all.ligne_suivante);

				end if; 
			end if; 		

		end Ajouter_contenu;

		resultat : T_Google_Creuse;
	begin 
		if Matrice_A.nb_ligne /= Matrice_B.nb_ligne or Matrice_A.nb_colonne /= Matrice_B.nb_colonne then 
			raise Dimensions_incompatibles_Error; 

		else 
			Resultat := Matrice_A;
			Ajouter_contenu(Resultat.contenu,Matrice_B.contenu);
			return Resultat; 
		end if; 
	end Somme;

	procedure Produit_scalaire_matrice(Matrice : in out T_Google_Creuse; scalaire : in T_Element) is

		coefficient : T_Element;
	begin 

		for i in 1..Matrice.nb_ligne loop 
			for j in 1..Matrice.nb_ligne loop 
				coefficient := Get_coefficient(Matrice,i,j); 
				Enregistrer_coefficient(Matrice,i,j,coefficient * scalaire); 
			end loop; 
		end loop; 
	End Produit_scalaire_matrice;


	function Egalite (Matrice_A : in T_Google_Creuse; Matrice_B : in T_Google_Creuse) return Boolean is 
		function Egalite_contenu  (V1, V2 : in T_Vecteur_Creux) return Boolean is
		begin 
			--Traiter les cas ou les vecteurs rentrés sont Nulls
			if V1 = Null or V2 = Null then
				return (V1=V2);

			else
				return Egalite_contenu(V1.All.ligne_suivante,V2.All.ligne_suivante);
			end if;
		end Egalite_contenu;
	begin

		--Traiter les cas ou les vecteurs rentrés sont Nulls
		if Matrice_A.nb_ligne /= Matrice_B.nb_ligne or Matrice_A.nb_colonne /= Matrice_B.nb_colonne then
			return False;

		else
			return Egalite_contenu(Matrice_A.contenu,Matrice_B.contenu);
		end if;
	end Egalite;


	-- NB : procédure utile pour le débugageg donc volontairement peu commentée/raffinée
	procedure Affichage (Matrice : in T_Google_Creuse) is
		curseur_ligne : T_Vecteur_Creux; 
		curseur_colonne : T_Vecteur_Creux;
		tmp_1 : T_Vecteur_Creux;
		tmp_2 : T_Vecteur_Creux;
		compteur : Integer;
	begin 

		-- Afficher matrice vide
		if Matrice.contenu = Null then
			Put("matrice creuse de taille : "); 
			Put(Matrice.nb_ligne,0); 
			Put(Matrice.nb_colonne,1);
			Put("[]");
		else

			curseur_ligne := Matrice.contenu; 
			compteur := 0; 

			-- Afficher ligne par ligne la matrice
			while compteur /= Matrice.nb_ligne loop 
				tmp_1 := curseur_ligne;
				curseur_colonne := curseur_ligne;
				compteur := compteur + 1; 

				if curseur_ligne /= Null and then curseur_ligne.all.indice_ligne = compteur then 
					
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
				
					curseur_ligne := curseur_ligne.all.ligne_suivante; 
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
				
			end loop; 
	       
		end if;
	End Affichage;

end google_creuse_lente;
