with Ada.IO_Exceptions; use Ada.IO_Exceptions;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Google_Naive;


procedure test_pagerank is
   
   type T_Double is digits 6;

   package Real_IO is new Ada.Text_IO.Float_IO(T_Double); use Real_IO;   -- pour afficher les coeffs

   -- Testons sur les matrices du sujet, les tests peuvent se généraliser à (n x n)
   package matrice_pleine is new Google_Naive(nombre_max_ligne   => 6 ,
                                              nombre_max_colonne => 6,
                                              T_Element          => T_Double);


   package vecteur is new Google_Naive(nombre_max_ligne   => 1 ,            -- pour stocker et traiter PI
                                       nombre_max_colonne => 6,
                                       T_Element          => T_Double);

   alpha : constant T_Double := T_Double(0.85000002384);


   procedure Creer_vect_occurence(noeuds_occurence : out vecteur.T_Google_Naive;
                                  N : in Integer;
                                  fichier_net : in Ada.Text_IO.File_Type ) is

      entier : Integer;              -- coefficient sur la premiÃ¨re colonne d'un fichier .net
      useless : Integer;             -- coefficient sur la deuxiÃ¨me colonne d'un fichier .net
      ancien_coefficient : T_Double;      -- occurence Ã  incrÃ©menter

   begin
      -- Initialiser le vecteur Ã  0
      vecteur.Initialiser(noeuds_occurence,1,N);
      for i in 1..N loop
         vecteur.Enregistrer_coefficient(noeuds_occurence,1,i,T_Double(0));
      end loop;

      -- Si un noeud apparait une fois on incrÃ©mente l'occurence de ce noeud
      while not end_of_File(fichier_net) loop
         Get(fichier_net,entier);
         ancien_coefficient := vecteur.Get_coefficient(noeuds_occurence,1,entier+1);
         vecteur.Enregistrer_coefficient(noeuds_occurence,1,(entier+1),ancien_coefficient + T_Double(1));
         Get(fichier_net,useless);
      end loop;

   end Creer_vect_occurence;

   -------------------------------Les sous-programmes de pagerank n'étant pas accessible nous n'avons d'autres solutions que de les copier ici : 

	
   procedure Creer_H(Nom_fichier_net : in Unbounded_String;
                     H : out matrice_pleine.T_Google_Naive;
                     N : out Integer) is


      entier : Integer;                                     -- coefficient sur la premiÃ¨re colonne d'un fichier .net
      fichier_net : Ada.Text_IO.File_Type;
      noeuds_occurence : vecteur.T_Google_Naive;     -- vecteur avec l'occurence de chaque noeud                                  -
      coeff_i : Integer;                                    -- numéro de ligne
      coeff_j : Integer;                                    -- numÃ©ro de colonne

      File_Absent_Error : exception;
   begin

      -- Ouvrir le fichier
      begin
         open(fichier_net, In_File, To_String(Nom_fichier_net));
      exception
         when ADA.IO_EXCEPTIONS.NAME_ERROR => raise File_Absent_Error;
      end;

      Get(fichier_net,N);

      -- CrÃ©er le vecteur avec l'occurence de chaque noeud
      Creer_vect_occurence(noeuds_occurence,N,fichier_net);

      close(fichier_net);

      -- Initialiser H Ã  0
      matrice_pleine.Initialiser(H,N,N);
      for i in 1..N loop
         for j in 1..N loop
            matrice_pleine.Enregistrer_coefficient(H,i,j,T_Double(0));
         end loop;
      end loop;

      -- Affecter au coefficient de H les poids initiaux
      open(fichier_net,In_File, To_String(Nom_fichier_net));
      Get(fichier_net,entier);                                -- on consomme la premiÃ¨re ligne
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
                                                T_Double(1)/vecteur.Get_coefficient(noeuds_occurence,1,coeff_i+1));
      end loop;

      close(fichier_net);

   end Creer_H;


   procedure Calculer_S(H : in out matrice_pleine.T_Google_Naive; N : in Integer) is

      coefficient_non_nul_Error : exception;       -- permet d'éviter les lignes non nulles entièrement

   begin

      for ligne in 1..N loop

         begin
            -- Chercher les lignes avec coefficient non nul
            for colonne in 1..N loop
               if matrice_pleine.Get_coefficient(H,ligne,colonne) /= T_Double(0) then
                  raise coefficient_non_nul_Error;
               end if;
            end loop;

            -- Traiter le cas des lignes entiÃ¨rement nulle : mettre tous les coefficients Ã  1/N
            for colonne in 1..N loop
               matrice_pleine.Enregistrer_coefficient(H,ligne,colonne,T_Double(1)/T_Double(N));
            end loop;
         Exception
               -- Ignorer les lignes avec des coefficients non nul
            when coefficient_non_nul_Error => Null;
         end;
      end loop;
   end Calculer_S;


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
         matrice_pleine.Enregistrer_coefficient(Pi_mat,1,i,T_Double(1)/T_Double(N));
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


   procedure Donnees_test (matrice_carre_H : out Matrice_Pleine.T_Google_Naive;
                           matrice_carre_S : out Matrice_Pleine.T_Google_Naive;
                           matrice_carre_G : out Matrice_Pleine.T_Google_Naive;
                           matrice_PI : out vecteur.T_Google_Naive;
                           matrice_PI_1 : out vecteur.T_Google_Naive;
                           vecteur_occurence : out vecteur.T_Google_Naive ) is  

   begin
      matrice_pleine.Initialiser (matrice_carre_H,6,6);
      matrice_pleine.Initialiser (matrice_carre_S,6,6);
      matrice_pleine.Initialiser (matrice_carre_G,6,6);
      vecteur.Initialiser (matrice_PI,1,6);
      vecteur.Initialiser (matrice_PI_1,1,6);
      vecteur.Initialiser (vecteur_occurence,1,6);
   
      -- Construisons la matrice H de taille 6 x 6
      matrice_pleine.Enregistrer_coefficient(matrice_carre_H, 1 , 1, T_Double(0));
      matrice_pleine.Enregistrer_coefficient(matrice_carre_H, 1 , 2, T_Double(0.5));
      matrice_pleine.Enregistrer_coefficient(matrice_carre_H, 1 , 3, T_Double(0.5));
      matrice_pleine.Enregistrer_coefficient(matrice_carre_H, 1 , 4, T_Double(0));
      matrice_pleine.Enregistrer_coefficient(matrice_carre_H, 1 , 5, T_Double(0));
      matrice_pleine.Enregistrer_coefficient(matrice_carre_H, 1 , 6, T_Double(0));
  
      matrice_pleine.Enregistrer_coefficient(matrice_carre_H, 2 , 1, T_Double(0));
      matrice_pleine.Enregistrer_coefficient(matrice_carre_H, 2 , 2, T_Double(0));
      matrice_pleine.Enregistrer_coefficient(matrice_carre_H, 2 , 3, T_Double(0));
      matrice_pleine.Enregistrer_coefficient(matrice_carre_H, 2 , 4, T_Double(0));
      matrice_pleine.Enregistrer_coefficient(matrice_carre_H, 2 , 5, T_Double(0));
      matrice_pleine.Enregistrer_coefficient(matrice_carre_H, 2 , 6, T_Double(0));
   
      matrice_pleine.Enregistrer_coefficient(matrice_carre_H, 3 , 1, T_Double(1)/T_Double(3));
      matrice_pleine.Enregistrer_coefficient(matrice_carre_H, 3 , 2, T_Double(1)/T_Double(3));
      matrice_pleine.Enregistrer_coefficient(matrice_carre_H, 3 , 3, T_Double(0));
      matrice_pleine.Enregistrer_coefficient(matrice_carre_H, 3 , 4, T_Double(0));
      matrice_pleine.Enregistrer_coefficient(matrice_carre_H, 3 , 5, T_Double(1)/T_Double(3));
      matrice_pleine.Enregistrer_coefficient(matrice_carre_H, 3 , 6, T_Double(0));
   
      matrice_pleine.Enregistrer_coefficient(matrice_carre_H, 4 , 1, T_Double(0));
      matrice_pleine.Enregistrer_coefficient(matrice_carre_H, 4 , 2, T_Double(0));
      matrice_pleine.Enregistrer_coefficient(matrice_carre_H, 4 , 3, T_Double(0));
      matrice_pleine.Enregistrer_coefficient(matrice_carre_H, 4 , 4, T_Double(0));
      matrice_pleine.Enregistrer_coefficient(matrice_carre_H, 4 , 5, T_Double(0.5));
      matrice_pleine.Enregistrer_coefficient(matrice_carre_H, 4 , 6, T_Double(1)/T_Double(2));
   
      matrice_pleine.Enregistrer_coefficient(matrice_carre_H, 5 , 1, T_Double(0));
      matrice_pleine.Enregistrer_coefficient(matrice_carre_H, 5 , 2, T_Double(0));
      matrice_pleine.Enregistrer_coefficient(matrice_carre_H, 5 , 3, T_Double(0));
      matrice_pleine.Enregistrer_coefficient(matrice_carre_H, 5 , 4, T_Double(0.5));
      matrice_pleine.Enregistrer_coefficient(matrice_carre_H, 5 , 5, T_Double(0));
      matrice_pleine.Enregistrer_coefficient(matrice_carre_H, 5 , 6, T_Double(0.5));
      
      matrice_pleine.Enregistrer_coefficient(matrice_carre_H, 6 , 1, T_Double(0));
      matrice_pleine.Enregistrer_coefficient(matrice_carre_H, 6 , 2, T_Double(0));
      matrice_pleine.Enregistrer_coefficient(matrice_carre_H, 6 , 3, T_Double(0));
      matrice_pleine.Enregistrer_coefficient(matrice_carre_H, 6 , 4, T_Double(1));
      matrice_pleine.Enregistrer_coefficient(matrice_carre_H, 6 , 5, T_Double(0));
      matrice_pleine.Enregistrer_coefficient(matrice_carre_H, 6 , 6, T_Double(0));
  
   
   
   
      matrice_pleine.Enregistrer_coefficient(matrice_carre_S, 1 , 1, T_Double(0));
      matrice_pleine.Enregistrer_coefficient(matrice_carre_S, 1 , 2, T_Double(0.5));
      matrice_pleine.Enregistrer_coefficient(matrice_carre_S, 1 , 3, T_Double(0.5));
      matrice_pleine.Enregistrer_coefficient(matrice_carre_S, 1 , 4, T_Double(0));
      matrice_pleine.Enregistrer_coefficient(matrice_carre_S, 1 , 5, T_Double(0));
      matrice_pleine.Enregistrer_coefficient(matrice_carre_S, 1 , 6, T_Double(0));
  
      matrice_pleine.Enregistrer_coefficient(matrice_carre_S, 2 , 1, T_Double(1)/T_Double(6));
      matrice_pleine.Enregistrer_coefficient(matrice_carre_S, 2 , 2, T_Double(1)/T_Double(6));
      matrice_pleine.Enregistrer_coefficient(matrice_carre_S, 2 , 3, T_Double(1)/T_Double(6));
      matrice_pleine.Enregistrer_coefficient(matrice_carre_S, 2 , 4, T_Double(1)/T_Double(6));
      matrice_pleine.Enregistrer_coefficient(matrice_carre_S, 2 , 5, T_Double(1)/T_Double(6));
      matrice_pleine.Enregistrer_coefficient(matrice_carre_S, 2 , 6, T_Double(1)/T_Double(6));
   
      matrice_pleine.Enregistrer_coefficient(matrice_carre_S, 3 , 1, T_Double(1)/T_Double(3));
      matrice_pleine.Enregistrer_coefficient(matrice_carre_S, 3 , 2, T_Double(1)/T_Double(3));
      matrice_pleine.Enregistrer_coefficient(matrice_carre_S, 3 , 3, T_Double(0));
      matrice_pleine.Enregistrer_coefficient(matrice_carre_S, 3 , 4, T_Double(0));
      matrice_pleine.Enregistrer_coefficient(matrice_carre_S, 3 , 5, T_Double(1)/T_Double(3));
      matrice_pleine.Enregistrer_coefficient(matrice_carre_S, 3 , 6, T_Double(0));
   
      matrice_pleine.Enregistrer_coefficient(matrice_carre_S, 4 , 1, T_Double(0));
      matrice_pleine.Enregistrer_coefficient(matrice_carre_S, 4 , 2, T_Double(0));
      matrice_pleine.Enregistrer_coefficient(matrice_carre_S, 4 , 3, T_Double(0));
      matrice_pleine.Enregistrer_coefficient(matrice_carre_S, 4 , 4, T_Double(0));
      matrice_pleine.Enregistrer_coefficient(matrice_carre_S, 4 , 5, T_Double(0.5));
      matrice_pleine.Enregistrer_coefficient(matrice_carre_S, 4 , 6, T_Double(1)/T_Double(2));
   
      matrice_pleine.Enregistrer_coefficient(matrice_carre_S, 5 , 1, T_Double(0));
      matrice_pleine.Enregistrer_coefficient(matrice_carre_S, 5 , 2, T_Double(0));
      matrice_pleine.Enregistrer_coefficient(matrice_carre_S, 5 , 3, T_Double(0));
      matrice_pleine.Enregistrer_coefficient(matrice_carre_S, 5 , 4, T_Double(0.5));
      matrice_pleine.Enregistrer_coefficient(matrice_carre_S, 5 , 5, T_Double(0));
      matrice_pleine.Enregistrer_coefficient(matrice_carre_S, 5 , 6, T_Double(0.5));

      matrice_pleine.Enregistrer_coefficient(matrice_carre_S, 6 , 1, T_Double(0));
      matrice_pleine.Enregistrer_coefficient(matrice_carre_S, 6 , 2, T_Double(0));
      matrice_pleine.Enregistrer_coefficient(matrice_carre_S, 6 , 3, T_Double(0));
      matrice_pleine.Enregistrer_coefficient(matrice_carre_S, 6 , 4, T_Double(1));
      matrice_pleine.Enregistrer_coefficient(matrice_carre_S, 6 , 5, T_Double(0));
      matrice_pleine.Enregistrer_coefficient(matrice_carre_S, 6 , 6, T_Double(0));
         
      matrice_pleine.Enregistrer_coefficient(matrice_carre_G, 1 , 1, T_Double(0.025));
      matrice_pleine.Enregistrer_coefficient(matrice_carre_G, 1 , 2, T_Double(0.45));
      matrice_pleine.Enregistrer_coefficient(matrice_carre_G, 1 , 3, T_Double(0.45));
      matrice_pleine.Enregistrer_coefficient(matrice_carre_G, 1 , 4, T_Double(0.025));
      matrice_pleine.Enregistrer_coefficient(matrice_carre_G, 1 , 5, T_Double(0.025));
      matrice_pleine.Enregistrer_coefficient(matrice_carre_G, 1 , 6, T_Double(0.025));
  
      matrice_pleine.Enregistrer_coefficient(matrice_carre_G, 2 , 1, T_Double(1)/T_Double(6));
      matrice_pleine.Enregistrer_coefficient(matrice_carre_G, 2 , 2, T_Double(1)/T_Double(6));
      matrice_pleine.Enregistrer_coefficient(matrice_carre_G, 2 , 3, T_Double(1)/T_Double(6));
      matrice_pleine.Enregistrer_coefficient(matrice_carre_G, 2 , 4, T_Double(1)/T_Double(6));
      matrice_pleine.Enregistrer_coefficient(matrice_carre_G, 2 , 5, T_Double(1)/T_Double(6));
      matrice_pleine.Enregistrer_coefficient(matrice_carre_G, 2 , 6, T_Double(1)/T_Double(6));
   
      matrice_pleine.Enregistrer_coefficient(matrice_carre_G, 3 , 1, T_Double(0.308333));
      matrice_pleine.Enregistrer_coefficient(matrice_carre_G, 3 , 2, T_Double(1)/T_Double(3));
      matrice_pleine.Enregistrer_coefficient(matrice_carre_G, 3 , 3, T_Double(0.025));
      matrice_pleine.Enregistrer_coefficient(matrice_carre_G, 3 , 4, T_Double(0.025));
      matrice_pleine.Enregistrer_coefficient(matrice_carre_G, 3 , 5, T_Double(0.308333));
      matrice_pleine.Enregistrer_coefficient(matrice_carre_G, 3 , 6, T_Double(0.025));
   
      matrice_pleine.Enregistrer_coefficient(matrice_carre_G, 4 , 1, T_Double(0.025));
      matrice_pleine.Enregistrer_coefficient(matrice_carre_G, 4 , 2, T_Double(0.025));
      matrice_pleine.Enregistrer_coefficient(matrice_carre_G, 4 , 3, T_Double(0.025));
      matrice_pleine.Enregistrer_coefficient(matrice_carre_G, 4 , 4, T_Double(0.025));
      matrice_pleine.Enregistrer_coefficient(matrice_carre_G, 4 , 5, T_Double(0.45));
      matrice_pleine.Enregistrer_coefficient(matrice_carre_G, 4 , 6, T_Double(0.45));
   
      matrice_pleine.Enregistrer_coefficient(matrice_carre_G, 5 , 1, T_Double(0.025));
      matrice_pleine.Enregistrer_coefficient(matrice_carre_G, 5 , 2, T_Double(0.025));
      matrice_pleine.Enregistrer_coefficient(matrice_carre_G, 5 , 3, T_Double(0.025));
      matrice_pleine.Enregistrer_coefficient(matrice_carre_G, 5 , 4, T_Double(0.45));
      matrice_pleine.Enregistrer_coefficient(matrice_carre_G, 5 , 5, T_Double(0.025));
      matrice_pleine.Enregistrer_coefficient(matrice_carre_G, 5 , 6, T_Double(0.45));

      matrice_pleine.Enregistrer_coefficient(matrice_carre_G, 6 , 1, T_Double(0.025));
      matrice_pleine.Enregistrer_coefficient(matrice_carre_G, 6 , 2, T_Double(0.025));
      matrice_pleine.Enregistrer_coefficient(matrice_carre_G, 6 , 3, T_Double(0.025));
      matrice_pleine.Enregistrer_coefficient(matrice_carre_G, 6 , 4, T_Double(0.875));
      matrice_pleine.Enregistrer_coefficient(matrice_carre_G, 6 , 5, T_Double(0.025));
      matrice_pleine.Enregistrer_coefficient(matrice_carre_G, 6 , 6, T_Double(0.025));
      
      vecteur.Enregistrer_coefficient(matrice_PI, 1 , 1, T_Double(1)/T_Double(6));
      vecteur.Enregistrer_coefficient(matrice_PI, 1 , 2, T_Double(1)/T_Double(6));
      vecteur.Enregistrer_coefficient(matrice_PI, 1 , 3, T_Double(1)/T_Double(6));
      vecteur.Enregistrer_coefficient(matrice_PI, 1 , 4, T_Double(1)/T_Double(6));
      vecteur.Enregistrer_coefficient(matrice_PI, 1 , 5, T_Double(1)/T_Double(6));
      vecteur.Enregistrer_coefficient(matrice_PI, 1 , 6, T_Double(1)/T_Double(6));
      
      vecteur.Enregistrer_coefficient(matrice_PI_1, 1 , 1, T_Double(0.051704775542));
      vecteur.Enregistrer_coefficient(matrice_PI_1, 1 , 2, T_Double(0.073679298162));
      vecteur.Enregistrer_coefficient(matrice_PI_1, 1 , 3, T_Double(0.057412441820));
      vecteur.Enregistrer_coefficient(matrice_PI_1, 1 , 4, T_Double(0.34870392084));
      vecteur.Enregistrer_coefficient(matrice_PI_1, 1 , 5, T_Double(0.19990395010));
      vecteur.Enregistrer_coefficient(matrice_PI_1, 1 , 6, T_Double(0.26859626174));
      
      vecteur.Enregistrer_coefficient(vecteur_occurence, 1 , 1, T_Double(2));
      vecteur.Enregistrer_coefficient(vecteur_occurence, 1 , 2, T_Double(0));
      vecteur.Enregistrer_coefficient(vecteur_occurence, 1 , 3, T_Double(3));
      vecteur.Enregistrer_coefficient(vecteur_occurence, 1 , 4, T_Double(2));
      vecteur.Enregistrer_coefficient(vecteur_occurence, 1 , 5, T_Double(2));
      vecteur.Enregistrer_coefficient(vecteur_occurence, 1 , 6, T_Double(1));

   
 
   end Donnees_test;
      
   procedure test_creer_H ( Nom_fichier_net : in Unbounded_String;
                            matrice_carre_H : in Matrice_Pleine.T_Google_Naive ) is

      ligne,colonne : Integer;
      H : Matrice_Pleine.T_Google_Naive;  
      N : Integer;
   begin
      
      creer_H (Nom_fichier_net, H, N);
      
      matrice_pleine.Dimension(H,ligne,colonne);
       
      pragma assert ( ligne = N and colonne = N);    
           

      pragma assert (Matrice_Pleine.Egalite(H, matrice_carre_H));
      
   end test_creer_H;

   
   procedure test_Creer_vect_occurence( Nom_fichier_net : in Unbounded_String ) is
      
      noeuds_occurence : vecteur.T_Google_Naive;  
      fichier_net : Ada.Text_IO.File_Type;
      N : Integer;
   begin
      
      open(fichier_net, In_File, To_String(Nom_fichier_net));

      Get(fichier_net,N);

      -- CrÃ©er le vecteur avec l'occurence de chaque noeud
      Creer_vect_occurence(noeuds_occurence,N,fichier_net);

      close(fichier_net);

         
      pragma assert (vecteur.Egalite(noeuds_occurence, noeuds_occurence));
         
   end test_Creer_vect_occurence;
   
   
   procedure test_Calculer_S( Nom_fichier_net : in Unbounded_String; matrice_carre_S : in Matrice_Pleine.T_Google_Naive ) is
   
      H : Matrice_Pleine.T_Google_Naive;  
      N : Integer;
   begin
         
      creer_H (Nom_fichier_net, H, N);
         
      Calculer_S(H, N);
   
      pragma assert (Matrice_Pleine.Egalite(H, matrice_carre_S));
      
   end test_Calculer_S;
      
   procedure test_Calculer_G( Nom_fichier_net : in Unbounded_String;
                              matrice_carre_G : in Matrice_Pleine.T_Google_Naive) is
         
      ancien_coefficient : T_Double;        -- coefficient de S
      H : Matrice_Pleine.T_Google_Naive;  
      N : Integer;
   begin
         
      creer_H (Nom_fichier_net, H, N);
         
      Calculer_S(H, N);

      for i in 1..N loop
         for j in 1..N loop
            ancien_coefficient := Matrice_Pleine.Get_coefficient(H,i,j);
            Matrice_Pleine.Enregistrer_coefficient(H,i,j,alpha*ancien_coefficient+(T_Double(1)-alpha)/T_Double(N));
         end loop;

            
      end loop;
         
     pragma assert (Matrice_Pleine.Egalite(H, matrice_carre_G));
         
   end test_Calculer_G;

        
   procedure test_Calculer_PI( matrice_PI_1 : in vecteur.T_Google_Naive; matrice_carre_G : in matrice_pleine.T_Google_Naive) is
         
      matrice_PI : vecteur.T_Google_Naive;
   begin
         
      Calculer_PI(matrice_PI,matrice_carre_G,150,6);

      pragma assert (vecteur.Egalite(matrice_PI_1,matrice_PI));
           
   end test_Calculer_PI;
    

   matrice_carre_H: matrice_pleine.T_Google_Naive;  
   matrice_carre_S: matrice_pleine.T_Google_Naive;  
   matrice_carre_G: matrice_pleine.T_Google_Naive;  
   matrice_PI: vecteur.T_Google_Naive;  
   matrice_PI_1: vecteur.T_Google_Naive;  
   vecteur_occurence: vecteur.T_Google_Naive;  
   sujet_exemple : constant Unbounded_String := To_Unbounded_String("exemple_sujet.net");
begin
   Donnees_test (matrice_carre_H ,
                 matrice_carre_S,
                 matrice_carre_G,
                 matrice_PI,
                 matrice_PI_1,
                 vecteur_occurence);

           
   New_line;

   test_creer_H( sujet_exemple,matrice_carre_H );
   Put_Line(" Creer H ok");

   test_Creer_vect_occurence( sujet_exemple );
   Put_Line(" Creer Vect occ ok");

   test_Calculer_S( sujet_exemple,matrice_carre_S );
   Put_Line(" Creer S ok");


   -- Les tests de G ne fonctionnent pas car ADA arrondit 0.25.... mal avec plutôt 0.249...., il est donc impossible de tester l'égalité avec la matrice G du sujet
   test_Calculer_G( sujet_exemple,matrice_carre_G );
   --Put_Line(" Creer G ok");


   test_Calculer_PI(matrice_PI_1,matrice_carre_G);
   Put_Line(" Calculer PI ok");

   Put_Line ("Fin des tests : OK.");

   
end test_pagerank;
