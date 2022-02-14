with Ada.Text_IO;           use Ada.Text_IO;
with Google_Naive;

procedure test_Google_Naive is

   type T_Double is digits 12;            -- les tests se font sur un type r�el particulier

   package Real_IO is new Ada.Text_IO.Float_IO(T_Double);      -- affichage de ce type

   -- Testons sur des matrices de petite taille (2x2 maximum), les tests peuvent se généraliser à (n x n)
   package Google_Naive_Tdouble is
     new Google_Naive (nombre_max_ligne => 2, nombre_max_colonne => 2
		       , T_Element => T_Double);
   use Google_Naive_Tdouble;


   -- Afficher � l'�cran les matrices
   procedure Afficher (test : in T_Double) is
   begin
      Real_IO.Put(test,1,10);
   end Afficher;
   procedure Affichage_matrice is new Google_Naive_Tdouble.Affichage(Afficher);


   -- Construire les données de test
   procedure Donnees_test (matrice_carre_A : out Google_Naive_Tdouble.T_Google_Naive;
			   matrice_carre_B : out Google_Naive_Tdouble.T_Google_Naive;
			   matrice_carre_C : out Google_Naive_Tdouble.T_Google_Naive;
			   matrice_vide : out Google_Naive_Tdouble.T_Google_Naive;
			   vecteur_ligne : out Google_Naive_Tdouble.T_Google_Naive;
			   vecteur_colonne : out Google_Naive_Tdouble.T_Google_Naive) is



   begin
      Initialiser (matrice_carre_A,2,2);
      Initialiser (matrice_carre_B,2,2);
      Initialiser (matrice_carre_C,2,2);
      Initialiser (matrice_vide,0,0);
      Initialiser (vecteur_ligne,1,2);
      Initialiser (vecteur_colonne,2,1);

      -- Construisons la matrice A de taille 2 x 2
      Enregistrer_coefficient(matrice_carre_A, 1 , 1, T_Double(1));
      Enregistrer_coefficient(matrice_carre_A, 1 , 2, T_Double(0.5));
      Enregistrer_coefficient(matrice_carre_A, 2 , 1, T_Double(2.0));
      Enregistrer_coefficient(matrice_carre_A, 2 , 2, T_Double(3.0));

      -- Construisons la matrice B de taille 2 x 2
      Enregistrer_coefficient(matrice_carre_B, 1 , 1, T_Double(4.0));
      Enregistrer_coefficient(matrice_carre_B, 1 , 2, T_Double(0.5));
      Enregistrer_coefficient(matrice_carre_B, 2 , 1, T_Double(0.4));
      Enregistrer_coefficient(matrice_carre_B, 2 , 2, T_Double(10.0));

      -- Construisons le vecteur ligne
      Enregistrer_coefficient(vecteur_ligne, 1 , 1, T_Double(1.0));
      Enregistrer_coefficient(vecteur_ligne, 1 , 2, T_Double(2.5));

      -- Construisons le vecteur colonne
      Enregistrer_coefficient(vecteur_colonne, 1 , 1, T_Double(6.0));
      Enregistrer_coefficient(vecteur_colonne, 2 , 1, T_Double(1.0));

   end Donnees_test;


   procedure Afficher_donnees_test (matrice_carre_A : in Google_Naive_Tdouble.T_Google_Naive;
				    matrice_carre_B : in Google_Naive_Tdouble.T_Google_Naive;
				    vecteur_ligne : in Google_Naive_Tdouble.T_Google_Naive;
				    vecteur_colonne : in Google_Naive_Tdouble.T_Google_Naive) is

   begin

      Affichage_matrice(matrice_carre_A);
      New_line;
      New_line;

      Affichage_matrice(matrice_carre_B);
      New_line;
      New_line;

      Affichage_matrice(vecteur_ligne);
      New_line;
      new_line;

      Affichage_matrice(vecteur_colonne);
   end Afficher_donnees_test;


   -- Tester la procédure Initialiser
   procedure test_initialiser ( matrice_carre_A : in Google_Naive_Tdouble.T_Google_Naive ) is
      ligne_A, colonne_A : Integer;

   begin

      Dimension ( matrice_carre_A, ligne_A, colonne_A );

      pragma assert ( ligne_A = 2 and colonne_A = 2 );

   end test_initialiser;

   -- Tester la procédure Est_Vide
   procedure test_Est_Vide ( matrice_vide: in Google_Naive_Tdouble.T_Google_Naive ) is
      ligne_V,colonne_V : Integer;       -- dimensions de la matrice vide
   begin

      Dimension ( matrice_vide,ligne_V,colonne_V );

      pragma assert ( ligne_V = 0 and colonne_V = 0 );

   end test_Est_Vide;

   -- Tester la procédure Get_coefficient
   procedure test_Get_coefficient( matrice_carre_A : in Google_Naive_Tdouble.T_Google_Naive ) is

      Coefficient : T_Double;

   begin

      Coefficient := Get_coefficient ( matrice_carre_A, 1, 1 );

      pragma assert ( Coefficient = T_Double(1.0) );

   end test_Get_coefficient;

   -- Tester la procédure Somme
   procedure test_somme ( matrice_carre_A : in Google_Naive_Tdouble.T_Google_Naive;
			  matrice_carre_B : in Google_Naive_Tdouble.T_Google_Naive) is

      matrice_carre_C : Google_Naive_Tdouble.T_Google_Naive;     -- resultat
      Coefficient1 : T_Double;                                 -- C[1,1]
      Coefficient2 : T_Double;                                 -- C[1,2]
      Coefficient3 : T_Double;                                 -- C[2,1]
      Coefficient4 : T_Double;                                 -- C[2,2]
      ligne,colonne : Integer;                                 -- dimensions de A

   begin
      Dimension(matrice_carre_A,ligne,colonne);
      Initialiser(matrice_carre_C,ligne,colonne);
      Affecter(matrice_carre_C,Somme(matrice_carre_A,matrice_carre_B));
      Coefficient1 := Get_coefficient ( matrice_carre_C, 1, 1 );
      Coefficient2 := Get_coefficient ( matrice_carre_C, 1, 2 );
      Coefficient3 := Get_coefficient ( matrice_carre_C, 2, 1 );
      Coefficient4 := Get_coefficient ( matrice_carre_C, 2, 2 );

      pragma assert ( Coefficient1 = T_Double(5.0) and Coefficient2 = T_Double(1.0) and Coefficient3 = T_Double(2.4) and Coefficient4 = T_Double(13.0) );

   end test_somme;

   -- Tester la procédure Produit_matrices
   procedure test_Produit_matrices ( matrice_carre_A : in Google_Naive_Tdouble.T_Google_Naive;
				     matrice_carre_B : in Google_Naive_Tdouble.T_Google_Naive) is

      matrice_carre_C : Google_Naive_Tdouble.T_Google_Naive;     -- resultat
      Coefficient1 : T_Double;                                 -- C[1,1]
      Coefficient2 : T_Double;                                 -- C[1,2]
      Coefficient3 : T_Double;                                 -- C[2,1]
      Coefficient4 : T_Double;                                 -- C[2,2]
      ligne_A,colonne_A : Integer;                             -- dimensions de A
      ligne_B,colonne_B : Integer;                             -- dimensions de B
   begin
      Dimension(matrice_carre_A,ligne_A,colonne_A);
      Dimension(matrice_carre_B,ligne_B,colonne_B);
      Initialiser(matrice_carre_C,colonne_A,ligne_B);

      Affecter(matrice_carre_C,Produit_matrices(matrice_carre_A,matrice_carre_B));

      Coefficient1 := Get_coefficient ( matrice_carre_C, 1, 1 );
      Coefficient2 := Get_coefficient ( matrice_carre_C, 1, 2 );
      Coefficient3 := Get_coefficient ( matrice_carre_C, 2, 1 );
      Coefficient4 := Get_coefficient ( matrice_carre_C, 2, 2 );

      pragma assert ( Coefficient1 = T_Double(4.2) and Coefficient2 = T_Double(5.5) and Coefficient3 = T_Double(9.2) and Coefficient4 = T_Double(31.0) );

   end test_Produit_matrices;

   -- Tester la procédure Produit_Scalaire_matrice
   procedure test_Produit_scalaire_matrice(matrice_carre_A : in out Google_Naive_Tdouble.T_Google_Naive ) is

      Coefficient1 : T_Double;                                 -- A[1,1]
      Coefficient2 : T_Double;                                 -- A[1,2]
      Coefficient3 : T_Double;                                 -- A[2,1]
      Coefficient4 : T_Double;                                 -- A[2,2]

   begin

      Produit_scalaire_matrice (matrice_carre_A, T_Double(10.0));
      Coefficient1 := Get_coefficient ( matrice_carre_A, 1, 1 );
      Coefficient2 := Get_coefficient ( matrice_carre_A, 1, 2 );
      Coefficient3 := Get_coefficient ( matrice_carre_A, 2, 1 );
      Coefficient4 := Get_coefficient ( matrice_carre_A, 2, 2 );

      pragma assert ( Coefficient1 = T_Double(10.0) and Coefficient2 = T_Double(5.0) and Coefficient3 = T_Double(20.0) and Coefficient4 = T_Double(30.0) );

   end test_Produit_scalaire_matrice;


   -- Tester la procédure Affecter
   procedure test_Affecter (matrice_carre_A : in out Google_Naive_Tdouble.T_Google_Naive;
			    matrice_carre_B : in Google_Naive_Tdouble.T_Google_Naive) is

   begin

      Affecter(matrice_carre_A, matrice_carre_B);
      pragma assert ( Egalite ( matrice_carre_A, matrice_carre_B ) );

   end test_Affecter;

   matrice_carre_A : T_Google_Naive;                         -- Donn�es de test
   matrice_carre_B : T_Google_Naive;
   matrice_carre_C : T_Google_Naive;
   matrice_vide : T_Google_Naive;
   vecteur_ligne : T_Google_Naive;
   vecteur_colonne : T_Google_Naive;


begin
   Donnees_test(matrice_carre_A,
		matrice_carre_B,
		matrice_carre_C,
		matrice_vide,
		vecteur_ligne,
		vecteur_colonne);

   Afficher_donnees_test (matrice_carre_A,
			  matrice_carre_B,
			  vecteur_ligne,
			  vecteur_colonne);
   New_line;

   test_initialiser( matrice_carre_A );
   Put_Line(" Initialiser ok");

   test_Est_Vide ( matrice_vide);
   Put_Line(" Est_Vide ok");

   test_Get_coefficient( matrice_carre_A);
   Put_Line(" Get_coefficient ok");

   test_somme ( matrice_carre_A,matrice_carre_B);
   Put_Line(" Somme ok");

   test_Produit_matrices ( matrice_carre_A, matrice_carre_B);
   Put_Line(" Produit matriciel ok");

   test_Produit_scalaire_matrice(matrice_carre_A);
   Put_Line(" Produit scalaire-matrice ok");

   test_Affecter (matrice_carre_A,matrice_carre_B);
   Put_Line(" Affecter ok");

   Put_Line ("Fin des tests : OK.");

end test_Google_Naive;
