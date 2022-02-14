with Recuperation_Argument;
with Ada.IO_Exceptions;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Google_Naive;
with Tri_par_tas;
with google_creuse;         -- si on souhaite utiliser une strcture vraiment 100% creuse � remplacer par google_creuse_lente et modifier le code en fonction

procedure pagerank is

   type T_precision is digits 6;                    -- type r�el des coefficients

   taille_tableau : constant Integer := 10000;      -- � adapter selon l'exemple test� !

   -- Import de tous les paquets nécessaires
   package Real_IO is new Ada.Text_IO.Float_IO(T_precision); use Real_IO;   -- pour afficher les coeffs

   package vecteur is new Google_Naive(nombre_max_ligne   => 1 ,            -- pour stocker et traiter PI
				       nombre_max_colonne => taille_tableau,
				       T_Element          => T_precision);

   package tri is new Tri_par_tas(1,taille_tableau ,T_precision,vecteur);   -- pour trier

   package recup is new Recuperation_Argument(T_alpha => T_precision);      -- pour r�cup�rer les arguments de la ligne de commande

   -- Procédures utiles pour le debugage et l'affichage des matrices
   --procedure Afficher_element (nombre : T_precision ) is
   --begin
   --   Put(nombre,1,16);
   --end Afficher_element;



   -- Nom : Creer_vect_occurrence
   -- Semantique : Construire le vecteur avec les occurences de chaque noeud
   -- Paramètres :
   -- noeuds_occurence : out matrice_pleine.T_Google_Naive;     -- vecteur occurence
   -- N : in Integer;                                           -- nombre de noeuds
   -- fichier_net : in Ada.Text_IO.File_Type;                   -- objet fichier pas le nom

   -- Pre : True;
   -- Post : trop complexe pour être exprimée;
   -- Tests
   -- Entrée : Sujet;     Sortie : [2,0,3,2,2,1]
   -- Exception : Aucune
   procedure Creer_vect_occurence(noeuds_occurence : out vecteur.T_Google_Naive;
				  N : in Integer;
				  fichier_net : in Ada.Text_IO.File_Type ) is

      entier : Integer;              -- coefficient sur la première colonne d'un fichier .net
      useless : Integer;             -- coefficient sur la deuxième colonne d'un fichier .net
      ancien_coefficient : T_precision;      -- occurence à incrémenter

   begin
      -- Initialiser le vecteur à 0
      vecteur.Initialiser(noeuds_occurence,1,N);
      for i in 1..N loop
	 vecteur.Enregistrer_coefficient(noeuds_occurence,1,i,T_precision(0));
      end loop;

      -- Si un noeud apparait une fois on incrémente l'occurence de ce noeud
      while not end_of_File(fichier_net) loop
	 Get(fichier_net,entier);
	 ancien_coefficient := vecteur.Get_coefficient(noeuds_occurence,1,entier+1);
	 vecteur.Enregistrer_coefficient(noeuds_occurence,1,(entier+1),ancien_coefficient + T_precision(1));
	 Get(fichier_net,useless);
      end loop;

   end Creer_vect_occurence;
   ------------------------------------------------------------------------------------------------------------------------------------IMPLANTATION NAIVE
   -- Nom : pagerank_t
   -- Semantique : Produire le vecteur PI d�fini dans le sujet avec des matrices pleines
   -- Paramètres :
   -- Nom_fichier_net : in Unbounded_String;                       -- fichier .net
   -- alpha : in T_precision;                                      -- coefficient de pondération
   -- N : in Integer;                                              -- nombre de noeuds
   -- iter_max : in Integer;                                       -- nombre d'iteration
   -- PI : out vecteur.T_Google_Naive;                             -- cf sujet

   -- Pre : True;
   -- Post : trop complexe pour être exprimée;
   -- Tests
   -- voir exemple_sujet
   -- Exception : Aucune (� part un storage error si le fichier.net est grand, pensez � changer la stack size)
   procedure pagerank_t (alpha : in T_precision;
			 Nom_fichier_net : in Unbounded_String;
			 N : out Integer;
			 iter_max : in Integer;
			 PI : out vecteur.T_Google_Naive )  is


      package matrice_pleine is new Google_Naive(nombre_max_ligne   => taille_tableau ,
						 nombre_max_colonne => taille_tableau,
						 T_Element          => T_precision);

      --procedure Affichage_vecteur is new Matrice_Pleine.Affichage (Afficher=>Afficher_element);



      --procedure Affichage_matrice_pleine is new matrice_pleine.Affichage (Afficher=>Afficher_element);


      -- Nom : Creer_H
      -- Semantique : Construire la matrice_pleine H définie dans le sujet
      -- Paramètres :
      -- Nom_fichier_net : in Unbounded_String;         -- nom du fichier.net
      -- H : out matrice_pleine.T_Google_Naive;         -- cf sujet
      -- N : in Integer;                                -- nombre de noeuds

      -- Pre : True;
      -- Post : trop complexe pour être exprimée;
      -- Tests
      -- voir exemple_sujet
      -- Exception : Aucune
      procedure Creer_H(Nom_fichier_net : in Unbounded_String;
			H : out matrice_pleine.T_Google_Naive;
			N : out Integer) is


	 entier : Integer;                                     -- coefficient sur la première colonne d'un fichier .net
	 fichier_net : Ada.Text_IO.File_Type;
	 noeuds_occurence : vecteur.T_Google_Naive;     -- vecteur avec l'occurence de chaque noeud                                  -
	 coeff_i : Integer;                                    -- num�ro de ligne
	 coeff_j : Integer;                                    -- numéro de colonne

      begin

	 -- Ouvrir le fichier
	 begin
	    open(fichier_net, In_File, To_String(Nom_fichier_net));
	 exception
	    when ADA.IO_EXCEPTIONS.NAME_ERROR => raise recup.File_Absent_Error;
	 end;

	 Get(fichier_net,N);

	 -- Créer le vecteur avec l'occurence de chaque noeud
	 Creer_vect_occurence(noeuds_occurence,N,fichier_net);

	 close(fichier_net);

	 -- Initialiser H à 0
	 matrice_pleine.Initialiser(H,N,N);
	 for i in 1..N loop
	    for j in 1..N loop
	       matrice_pleine.Enregistrer_coefficient(H,i,j,T_precision(0));
	    end loop;
	 end loop;

	 -- Affecter au coefficient de H les poids initiaux
	 open(fichier_net,In_File, To_String(Nom_fichier_net));
	 Get(fichier_net,entier);                                -- on consomme la première ligne
	 while not end_of_File(fichier_net) loop

	    -- Lire le coefficient i,j
	    Get(fichier_net,entier);
	    coeff_i := entier;
	    Get(fichier_net,entier);
	    coeff_j := entier;
	    -- Enregistrer 1/occurence au coefficient i,j de H
	    matrice_pleine.Enregistrer_coefficient(H,
					    coeff_i+1,
					    coeff_j+1,
					    T_precision(1)/vecteur.Get_coefficient(noeuds_occurence,1,coeff_i+1));
	 end loop;

	 close(fichier_net);

      end Creer_H;


      -- Nom : Calculer_S
      -- Semantique : Construire la matrice_pleine S
      -- Paramètres :
      -- H : in out matrice_pleine.T_Google_Naive;        -- H est le S d�fini dans le sujer
      -- N : in Integer;
      -- Pre : True;
      -- Post : les anciennes lignes nulles sont à 1/N
      -- Tests
      -- voir exemple_sujet
      -- Exception: Aucune
      procedure Calculer_S(H : in out matrice_pleine.T_Google_Naive; N : in Integer) is

	 coefficient_non_nul_Error : exception;       -- permet d'�viter les lignes non nulles enti�rement

      begin

	 for ligne in 1..N loop

	    begin
	       -- Chercher les lignes avec coefficient non nul
	       for colonne in 1..N loop
		  if matrice_pleine.Get_coefficient(H,ligne,colonne) /= T_precision(0) then
		     raise coefficient_non_nul_Error;
		  end if;
	       end loop;

	       -- Traiter le cas des lignes entièrement nulle : mettre tous les coefficients à 1/N
	       for colonne in 1..N loop
		  matrice_pleine.Enregistrer_coefficient(H,ligne,colonne,T_precision(1)/T_precision(N));
	       end loop;
	    Exception
		  -- Ignorer les lignes avec des coefficients non nul
	       when coefficient_non_nul_Error => Null;
	    end;
	 end loop;
      end Calculer_S;

      -- Nom : Calculer_PI
      -- Semantique : calculer le vecteur PI
      -- Paramètres :
      -- PI : out vecteur.T_Google_Naive;
      -- H : in matrice_pleine.T_Google_Naive;
      -- iter_max : in Integer;
      -- N : in Integer;
      -- Pre : True;
      -- Post : trop complexe pour être exprimée;
      -- Tests
      -- voir exemple_sujet
      -- Exception : Aucune
      procedure Calculer_PI (PI : out vecteur.T_Google_Naive;
			     H : in matrice_pleine.T_Google_Naive;
			     iter_max : in Integer;
			     N : in Integer) is

	 Pi_mat : matrice_pleine.T_Google_Naive;        -- version matricielle de PI
	 iteration : Integer;
	 Pi_temp : matrice_pleine.T_Google_Naive;        -- stocke la valeur de PI temporairement
      begin
	 matrice_pleine.Initialiser(PI_mat,1,N);

	 -- Initialiser PI
	 for i in 1..N loop
	    matrice_pleine.Enregistrer_coefficient(Pi_mat,1,i,T_precision(1)/T_precision(N));
	 end loop;

	 -- Faire le produit PI*G iter_max fois
	 iteration := 0;
	 matrice_pleine.Initialiser(PI_temp,1,N);
	 while  iteration <= iter_max loop


	    matrice_pleine.Affecter(PI_temp,matrice_pleine.produit_matrices(PI_mat,H));
	    matrice_pleine.Affecter(PI_mat,PI_temp);
	    iteration := iteration + 1;
	 end loop;

	 -- Conversion de PI matriciel en Pi vecteur
	 vecteur.Initialiser(PI,1,N);
	 for i in 1..N loop
	    vecteur.Enregistrer_coefficient(PI,1,i,matrice_pleine.Get_coefficient(Pi_mat,1,i));
	 end loop;

      end Calculer_PI;

      ancien_coefficient : T_precision;        -- coefficient de S
      H : matrice_pleine.T_Google_Naive;

   begin

      Creer_H(Nom_fichier_net,H,N);

      Calculer_S(H,N);

      -- Calculer G
      for i in 1..N loop
	 for j in 1..N loop
	    ancien_coefficient := matrice_pleine.Get_coefficient(H,i,j);
	    matrice_pleine.Enregistrer_coefficient(H,i,j,alpha*ancien_coefficient+(T_precision(1)-alpha)/T_precision(N));
	 end loop;

      end loop;

      Calculer_PI (PI,H,iter_max,N);

   end pagerank_t;





   --------------------------------------------------------------------------------------------------------------------------- IMPLANTATION CREUSE
   -- Nom : pagerank_c
   -- Semantique : Produire le vecteur PI d�fini dans le sujet avec des matrices creuses
   -- Paramètres :
   -- Nom_fichier_net : in Unbounded_String;                       -- fichier .net
   -- alpha : in T_precision;                                      -- coefficient de pondération
   -- N : in Integer;                                              -- nombre de noeuds
   -- iter_max : in Integer;                                       -- nombre d'iteration
   -- PI : out vecteur.T_Google_Naive;                             -- cf sujet

   -- Pre : True;
   -- Post : trop complexe pour être exprimée;
   -- Tests
   -- voir exemple_sujet
   -- Exception : Aucune (� part un storage error si le fichier.net est grand, pensez � changer la stack size)
   procedure pagerank_c (alpha : in T_precision;
			 Nom_fichier_net : in Unbounded_String;
			 iter_max : in Integer;
			 N : out Integer;
			 PI : out vecteur.T_Google_Naive)  is


      package matrice_creuse is new google_creuse(T_Element      => T_precision,
						  nb_max_ligne   => taille_tableau);

      -- Procédures utiles pour le debugage
      --procedure Afficher_element (nombre : T_precision ) is
      --begin
      -- Put(nombre,1,10);
      --end Afficher_element;

      --procedure Affichage_matrice_creuse is new matrice_creuse.Affichage (Afficher=>Afficher_element);



      -- Nom : Creer_H
      -- Semantique : Construire la matrice_creuse H définie dans le sujet
      -- Paramètres :
      -- Nom_fichier : in Unbounded_String;               -- nom du fichier .net
      -- H : out matrice_creuse.T_Google_Creuse;
      -- N : in Integer;                                  -- nombre de noeuds

      -- Pre : True;
      -- Post : trop complexe pour être exprimée;
      -- Tests
      -- voir exemple_sujet
      -- Exception : Aucune
      procedure Creer_H(Nom_fichier_net : in Unbounded_String;
			H : out matrice_creuse.T_Google_Creuse;
			N : out Integer) is



	 entier : Integer;                              -- coefficient sur la première colonne d'un fichier .net
	 fichier_net : Ada.Text_IO.File_Type;
	 noeuds_occurence : vecteur.T_Google_Naive;     -- vecteur avec l'occurence de chaque noeud                                  -- taille de la matrice_creuse
	 coeff_i : Integer;
	 coeff_j : Integer;                              -- numéro de colonne

      begin

	 -- Ouvrir le fichier
	 begin
	    open(fichier_net, In_File, To_String(Nom_fichier_net));
	 exception
	    when ADA.IO_EXCEPTIONS.NAME_ERROR => raise recup.File_Absent_Error;
	 end;

	 Get(fichier_net,N);

	 -- Créer le vecteur avec l'occurence de chaque noeud
	 Creer_vect_occurence(noeuds_occurence,N,fichier_net);

	 close(fichier_net);

	 -- Initialiser H à 0
	 matrice_creuse.Initialiser(H,N,N);
	 for i in 1..N loop
	    for j in 1..N loop
	       matrice_creuse.Enregistrer_coefficient(H,i,j,T_precision(0));
	    end loop;
	 end loop;

	 -- Affecter au coefficient de H les poids initiaux
	 open(fichier_net,In_File, To_String(Nom_fichier_net));
	 Get(fichier_net,entier);                                -- on consomme la première ligne
	 while not end_of_File(fichier_net) loop
	    -- Lire le coefficient i,j
	    Get(fichier_net,entier);
	    coeff_i := entier;
	    Get(fichier_net,entier);
	    coeff_j := entier;
	    -- Enregistrer 1/occurence au coefficient i,j de H
	    matrice_creuse.Enregistrer_coefficient(H,
					    coeff_i+1,
					    coeff_j+1,
					    T_precision(1)/vecteur.Get_coefficient(noeuds_occurence,1,coeff_i+1));
	 end loop;

	 close(fichier_net);

      end Creer_H;


      -- Nom : Calculer_S
      -- Semantique : Construire la matrice_creuse S
      -- Paramètres :
      -- H : in out matrice_creuse.T_Google_Creuse;         -- en r�alit� S
      -- N : in Integer;                                    -- nombre de noeuds
      -- Pre : True;
      -- Post : les anciennes lignes nulles sont à 1/N
      -- Tests
      -- voir exemple_sujet
      -- Exception : Aucune
      procedure Calculer_S(H : in out matrice_creuse.T_Google_Creuse; N : in Integer) is

	 coefficient_non_nul_Error : exception;

      begin
	 for ligne in 1..N loop

	    begin
	       -- Chercher les lignes avec coefficient non nul
	       for colonne in 1..N loop
		  if matrice_creuse.Get_coefficient(H,ligne,colonne) /= T_precision(0) then
		     raise coefficient_non_nul_Error;
		  end if;
	       end loop;

	       -- Traiter le cas des lignes entièrement nulle : mettre tous les coefficients à 1/N
	       for colonne in 1..N loop
		  matrice_creuse.Enregistrer_coefficient(H,ligne,colonne,T_precision(1)/T_precision(N));
	       end loop;
	    Exception
		  -- Ignorer les lignes avec des coefficients non nul
	       when coefficient_non_nul_Error => Null;
	    end;
	 end loop;
      end Calculer_S;

      -- Nom : Calculer_PI
      -- Semantique : calculer le vecteur PI PI
      -- Paramètres :
      -- PI : out vecteur.T_Google_Naive;               -- cf sujet
      -- H : in matrice_creuse.T_Google_Creuse;
      -- iter_max : in Integer;
      -- N : in Integer;                                 -- nombre de noeuds
      -- Pre : True;
      -- Post : trop complexe pour être exprimée;
      -- Tests
      -- voir exemple_sujet
      -- Exception : Aucuune
      procedure Calculer_PI (PI : out vecteur.T_Google_Naive;
			     H : in matrice_creuse.T_Google_Creuse;
			     iter_max : in Integer;
			     alpha : in T_precision;
			     N : in Integer) is

	 -- Nom : Pi_fois_G
	 -- Semantique : Calculer itérativement Pi en tirant profit du fait que G est creuse
	 -- Paramètres :
	 -- Resultat : out vecteur.T_Google_Naive;         --! une fonction aurait été plus logique mais ADA ne permet pas de renvoyer un type privé
	 -- H : in out matrice_creuse.T_Google_Creuse;      -- matrice d'adjacence creuse de G
	 -- N : in Integer;                                 -- Nombre de noeuds
	 -- Pre : True;
	 -- Post : complexe à exprimer en algorithmique
	 -- Tests : Aucune
	 -- Exception : Aucune
	 procedure PI_fois_G(Resultat : out vecteur.T_Google_Naive;
		      PI : in vecteur.T_Google_Naive;
		      alpha : in T_precision;
		      G : in matrice_creuse.T_Google_Creuse ) is

	    ligne,colonne : Integer;          -- dimensions de PI
	    coefficient : T_precision;        -- coefficient � consid�rer pour la somme
	    coefficient_G,coeff_PI : T_precision;
	    somme : T_precision;                         -- valeur du nouveau PI(1,J)

	 begin

	    vecteur.Dimension(PI,ligne,colonne);
	    vecteur.Initialiser(Resultat,ligne,colonne);

	    -- Calculer tous les nouveaux PI(1,i)
	    for i in 1..colonne loop

	       somme := T_precision(0);

	       -- Faire la somme des PI(1,k)*G(k,i)
	       for j in 1..colonne loop

		  coefficient_G := matrice_creuse.Get_coefficient(Matrice => G,ligne => j,colonne => i);

		  -- Remplacer les O par (1-alpha)/N pour le calcul
		  if coefficient_G = 0.0 then
		     coefficient := ((T_precision(1)-alpha)/T_precision(colonne));
		  else
		     coefficient := coefficient_G;
		  end if;

		  coeff_PI := vecteur.Get_coefficient(PI,1,j);
		  somme := somme + coeff_PI*coefficient;

	       end loop;
	       vecteur.Enregistrer_coefficient(Resultat,1,i,somme);
	    end loop;
	 end PI_fois_G;

	 iteration : Integer;
	 Pi_temp : vecteur.T_Google_Naive;

      begin

	 vecteur.Initialiser(PI,1,N);

	 -- Initialiser PI
	 for i in 1..N loop
	    vecteur.Enregistrer_coefficient(PI,1,i,T_precision(1)/T_precision(N));
	 end loop;

	 -- Faire le produit PI*G iter_max fois
	 iteration := 0;
	 vecteur.Initialiser(PI_temp,1,N);
	 while  iteration <= iter_max loop

	    -- Calculer PI*G
	    PI_fois_G(PI_temp,PI,alpha,H);
	    vecteur.Affecter(PI,PI_temp);
	    iteration := iteration + 1;
	 end loop;

      end Calculer_PI;

      H : matrice_creuse.T_Google_Creuse;
      ancien_coefficient : T_precision;

   begin
      Creer_H(Nom_fichier_net,H,N);

      Calculer_S(H,N);

      -- Calculer G
      for i in 1..N loop
	 for j in 1..N loop
	    ancien_coefficient := matrice_creuse.Get_coefficient(H,i,j);

	    if ancien_coefficient = T_precision(0) then      -- Ne pas stocker les (1-alpha)/N => les 0 les repr�senteront dans les calculs
	       Null;
	    else
	       matrice_creuse.Enregistrer_coefficient(H,i,j,alpha*ancien_coefficient+(T_precision(1)-alpha)/T_precision(N));
	    end if;
	 end loop;
      end loop;

      Calculer_PI (PI,H,iter_max,alpha,N);
      matrice_creuse.Detruire(H);
   end pagerank_c;


   -- Nom : Afficher_parametre
   -- Semantique : Afficher la valeur des paramètres choisis
   -- Paramètres :
   -- alpha : in T_precision;        -- coefficient de pondération
   -- iter_max : in Integer;         -- nombre d'iteration
   -- naive : in Boolean;            -- matrice_pleine ?
   -- Nom_fichier_net : in Unbounded_String;
   -- Pre : True;
   -- Post : True;
   -- Tests
   -- Entrée : alpha = 0.85, iter_max = 150, naive = True, Nom_fichier_net = fichier.net
   -- Sortie :
   -- alpha :8.5000000000E-01
   -- iteration : 150
   -- mode creux
   -- nom du fichier : exemple_sujet.net
   procedure Afficher_parametre (alpha : in T_precision;
				 iter_max : in INteger;
				 naive : in Boolean;
				 Nom_fichier_net : in Unbounded_String)is

   begin
      -- Afficher alpha
      Put("alpha :");
      Put(alpha,Fore=>1,Aft=>10);
      New_Line;
      -- Afficher iteration
      Put("iteration : ");
      Put(iter_max,0);
      New_Line;

      -- Afficher le mode
      if naive then
	 Put("mode naif");
      else
	 Put("mode creux");
      end if;

      -- Afficher Nom_fichier
      New_Line;
      Put("nom du fichier : ");
      Put(To_String(Nom_fichier_net));
      New_Line;
   end Afficher_parametre;

   -- Nom : Enregistrer_fichier_poids
   -- Semantique : Ecrire le fichier en .p
   -- Paramètres :
   -- Nom_fichier_brut : in Unbounded_String;        -- nom du fichierd'origine sans le ".net"
   -- poids : in tri.T_vecteur_couple;               -- vecteur constitu� des couples (poids:indice initial) et surtut rang� dans l'ordre d�croissant des poids
   -- N : in Integer;
   -- iter_max : in Integer;
   -- alpha : in T_precision;
   -- Pre : True;
   -- Post : True;
   -- Tests : Aucun
   -- Exception : Aucune
   procedure Ecrire_fichier_poids(Nom_fichier_brut : in Unbounded_String;
				  poids : in tri.T_vecteur_couple;
				  N : in Integer;
				  iter_max : in Integer;
				  alpha : in T_precision) is

      fichier_p : Ada.Text_IO.File_Type;      -- objet fichier
      Nom_fichier_p : Unbounded_String;       -- nom du fichier
   begin

      Nom_fichier_p := Nom_fichier_brut & To_Unbounded_String(".p");

      create(fichier_p,Out_File, To_String(Nom_fichier_p));

      -- Ecrire la première ligne
      Put(fichier_p,N,0);
      Put(fichier_p,' ');
      Real_IO.Put(fichier_p, alpha,
		  Fore=>1,
		  Aft=>10);
      Put(fichier_p,' ');
      Put(fichier_p, iter_max,0);
      New_line(fichier_p);

      -- Ecrire le reste du fichier Poids
      for i in 1..poids.taille loop
	 Real_IO.Put(File => fichier_p,
	      Item => poids.vecteur(i).weight,
	      Fore=>1,
	      Aft=>10);
	 New_line(fichier_p);
      end loop;
      close (fichier_p);
   end Ecrire_fichier_poids;

   -- Nom : Enregistrer_fichier_ord
   -- Semantique : Ecrire le fichier en .ord
   -- Paramètres :
   -- Nom_fichier_brut : in Unbounded_String;      -- cf ci -dessus
   -- poids : in tri.T_vecteur_couple;
   -- N : in Integer;
   -- Pre : True;
   -- Post : True;
   -- Tests : Aucun
   -- Exception : Aucune
   procedure Ecrire_fichier_ord(Nom_fichier_brut : in Unbounded_String;
				poids : in tri.T_vecteur_couple) is

      fichier_ord : Ada.Text_IO.File_Type;
      Nom_fichier_ord : Unbounded_String;
   begin

      Nom_fichier_ord := Nom_fichier_brut & To_Unbounded_String(".ord");

      create(fichier_ord,Out_File, To_String(Nom_fichier_ord));

      -- Ecrire ligne par ligne les indices
      for i in 1..poids.taille loop
	 Ada.Integer_Text_IO.Put(File=> fichier_ord,
			  Item => poids.vecteur(i).indice);
	 New_line(fichier_ord);
      end loop;
      close (fichier_ord);
   end Ecrire_fichier_ord;


   alpha : T_precision;                                         -- coefficient de pond�ration
   iter_max : Integer;                                          -- nombre d'iteration
   taille : Integer;                                            -- taille de la chaine nom_fichier
   naive : Boolean;                                             -- mode de calcul
   Nom_fichier_net, Nom_fichier_brut : Unbounded_String;        -- nom des fichiers avec et sans ".net"
   N :Integer;                                                  -- nombre de noeuds
   PI : vecteur.T_Google_Naive;                                 -- défini dans le sujet
   poids : tri.T_vecteur_couple;                                -- vecteur de couple (indice:poids)


begin
   -- Récupérer les arguments de la ligne de commande
   recup.Recuperer_valeurs_option(alpha, iter_max, naive, Nom_fichier_net);

   -- Afficher les valeurs des paramètres
   Afficher_parametre(alpha, iter_max, naive, Nom_fichier_net);


   -- Calculer PI
   if naive then
      pagerank_t(alpha,Nom_fichier_net,N,iter_max,PI);
   else
      pagerank_c(alpha,Nom_fichier_net,iter_max,N,PI);
   end if;


   -- Trier les noeuds par ordre décroissant du poids
   tri.Initialiser_poids(PI,poids);
   tri.Tri_tas(poids);

   -- Ecrire les fichiers

   taille := Length(Nom_fichier_net);

   -- Ecrire le fichier .P
   Nom_fichier_brut := To_Unbounded_String(To_String(Nom_fichier_net)(1..taille-4));

   Ecrire_fichier_poids(Nom_fichier_brut,poids,N,iter_max,alpha);

   -- Ecrire le fichier .ord
   Ecrire_fichier_ord(Nom_fichier_brut,poids);
end pagerank;
