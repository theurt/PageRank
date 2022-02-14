with Ada.Containers.Generic_Constrained_Array_Sort;
with Alea;
with tri_par_tas;
with Ada.Text_IO;           use Ada.Text_IO;
with Ada.Float_Text_IO;   use Ada.Float_Text_IO;
with Ada.Integer_Text_IO;   use Ada.Integer_Text_IO;
with Google_Naive;

procedure test_Tri_par_tas is


   taille_vecteur : constant Integer := 20;                   -- ne pas dépasser 10000 car les données de tests auront des poids identiques sinon

	package matrice is new Google_Naive(nombre_max_ligne   => 1,
nombre_max_colonne => taille_vecteur,
T_Element          => Float);

   package Tri is new Tri_par_tas(1,taille_vecteur,Float, matrice);

   function is_greater (Left  : in Tri.T_couple; Right : in Tri.T_couple) return Boolean is
   begin
      return (Left.weight > Right.weight);
   end is_greater;

   -- Procédure générique du langage qui va nous permettre de vérifier notre tri
   procedure tri_ada is new Ada.Containers.Generic_Constrained_Array_Sort(Index_Type   => Tri.List_Index,
                                                                          Element_Type => Tri.T_couple ,
                                                                          Array_Type   => Tri.T_vecteur,
                                                                          "<"          => is_greater);

   -- package qui va nous permettre de générer des vecteurs poids aléatoires
   package Mon_Alea is
     new Alea (1, 1000000);  -- générateur de nombre dans l'intervalle [1, 100000000]=> aucun poids devrait être identique
   use Mon_Alea;

   subtype v_simple is Matrice.T_Google_Naive;

   -- Afficher les vecteurs triés
   procedure Afficher (vecteur : Tri.T_vecteur_couple) is
   begin
      Put('[');
      for i in 1..vecteur.taille loop
         Put("( ");
         Put(vecteur.vecteur(i).indice,0);
         Put(" : ");
         Put(vecteur.vecteur(i).weight,0);
         Put(", )");
      end loop;
      Put(']');
   end Afficher;


   -- procedure servant au debugage pour afficher les matrices à trier
   --procedure Afficher_element (nombre : float) is
   --begin
   --	Put(nombre);
   --end Afficher_element;

   --procedure Affichage_matrice is new Matrice.Affichage (Afficher=>Afficher_element);



   -- Générer des données de test
   procedure Donnees_test(vecteur_null : out v_simple;
                          vect_court_trie : out v_simple;
                          vect_court_moyen : out v_simple;
                          vect_long_trie : out v_simple;
                          vect_long_moyen : out  v_simple) is

      indice : Integer;
      nb_entier_aleatoire : Integer;
      nb_reel_aleatoire : Float;

   begin
      -- Initialiser les vecteurs
      Matrice.Initialiser(vecteur_null,0,0);
      Matrice.Initialiser(vect_court_trie,1,10);
      Matrice.Initialiser(vect_court_moyen,1,10);
      Matrice.Initialiser(vect_long_trie,1, taille_vecteur);
      Matrice.Initialiser(vect_long_moyen,1,taille_vecteur);


      -- Créer les vecteurs de petite taille

      -- Vecteur Déjà trié
      for i in 1..10 loop
         Matrice.Enregistrer_coefficient(vect_court_trie,1,i,float(i));
      end loop;

      -- Vecteur moyen (cad pas trop mélangé): utilisons l'aléatoire
      for i in 1..10 loop
         Get_Random_Number(nb_entier_aleatoire);
         nb_reel_aleatoire := float(0.1)*float(nb_entier_aleatoire);
         Matrice.Enregistrer_coefficient(vect_court_moyen,1,i,nb_reel_aleatoire);
      end loop;

      -- Créer un vecteur de grande taille

      --Vecteur déjà trié
      indice := 1;
      for i in 1..taille_vecteur loop
         Matrice.Enregistrer_coefficient(vect_long_trie,1,indice,float(i));
         indice := indice +1;
      end loop;

      -- Vecteur moyen (cad pas trop mélangé), utilisons l'aléatoire
      for i in 1..taille_vecteur loop
         Get_Random_Number (nb_entier_aleatoire);
         nb_reel_aleatoire := 0.1*Float(nb_entier_aleatoire);
         Matrice.Enregistrer_coefficient(vect_long_moyen,1,i,nb_reel_aleatoire);
      end loop;
   end Donnees_test;

   -- Tester l'égalité entre deux vecteurs triés
   function Egalite_vecteur_couple (v1 : in Tri.T_vecteur_couple; v2 : in Tri.T_vecteur_couple) return Boolean is

      indicateur : Boolean;

   begin
      indicateur := True;
      if v1.taille /= v2.taille then      -- les tailles sont déjà différentes
         return False;
      else
         -- Vérifier élément par élément
         for i in 1..v1.taille loop
            if v1.vecteur(i).indice /= v2.vecteur(i).indice or v2.vecteur(i).weight /= v1.vecteur(i).weight then
               indicateur := False;
            end if;
         end loop;
      end if;
      return indicateur;
   end Egalite_vecteur_couple;


   -- tester la procédure créant les vecteurs couples
   procedure test_Initialiser_poids (
                                     vect_court_trie : in v_simple;
                                     vect_court_moyen : in v_simple;
                                     vect_long_trie : in v_simple;
                                     vect_long_moyen : in v_simple;
                                     vect_court_trie_couple : out Tri.T_vecteur_couple;         -- Données de tests
                                     vect_court_moyen_couple : out Tri.T_vecteur_couple;
                                     vect_long_trie_couple : out Tri.T_vecteur_couple;
                                     vect_long_moyen_couple : out Tri.T_vecteur_couple) is

      -- fonction qui va nous aider à vérifier nos tests (elle a été écrite par une personne différente et permet donc de comparer)
      procedure Enregistrer_vraie_valeur(vecteur : in v_simple; vecteur_double : out Tri.T_vecteur_couple)is

         coefficient : Tri.T_couple;
         ligne,colonne : Integer;
      begin
         Matrice.Dimension(vecteur,ligne,colonne);
         vecteur_double.taille := 0;
         for i in 1..colonne loop
            coefficient.indice := i-1;
            coefficient.weight := MATRICE.Get_coefficient(Matrice => vecteur,
                                                                     ligne   => ligne,
                                                                     colonne => i );

            vecteur_double.vecteur(i):=coefficient;
            vecteur_double.taille := vecteur_double.taille+1;
         end loop;
      end Enregistrer_vraie_valeur;


      verif_1 : Tri.T_vecteur_couple;         -- vecteur de vérification
      verif_2 : Tri.T_vecteur_couple;
      verif_3 : Tri.T_vecteur_couple;
      verif_4 : Tri.T_vecteur_couple;
   begin

      -- Créer les vecteurs couples obtenu avec le module tri
      TRi.Initialiser_poids(vect_court_trie, vect_court_trie_couple);
      TRi.Initialiser_poids(vect_court_moyen, vect_court_moyen_couple);
      TRi.Initialiser_poids(vect_long_trie, vect_long_trie_couple);
      TRi.Initialiser_poids(vect_long_moyen, vect_long_moyen_couple);

      -- Créer les vecteurs de vérification
      Enregistrer_vraie_valeur(vect_court_trie,verif_1);
      Enregistrer_vraie_valeur(vect_court_moyen,verif_2);
      Enregistrer_vraie_valeur(vect_long_trie,verif_3);
      Enregistrer_vraie_valeur(vect_long_moyen,verif_4);

      -- Comparer avec les "vraies valeurs"
      pragma assert(Egalite_vecteur_couple(verif_1,vect_court_trie_couple));
      pragma assert(Egalite_vecteur_couple(verif_2,vect_court_moyen_couple));
      pragma assert(Egalite_vecteur_couple(verif_3,vect_long_trie_couple));
      pragma assert(Egalite_vecteur_couple(verif_4,vect_long_moyen_couple));
   end test_Initialiser_poids;


   -- Tester le tri par tas
   procedure test_Tri_tas (vect_court_trie : in out Tri.T_vecteur_couple;
                           vect_court_moyen : in out Tri.T_vecteur_couple;
                           vect_long_trie : in out Tri.T_vecteur_couple;
                           vect_long_moyen : in out Tri.T_vecteur_couple) is


      -- Procédure auxiliaire nécessaire pour inverser un vecteur trié par ada dans l'ordre croissant
      procedure inverser_ordre_vecteur(vect : in out TRi.T_vecteur_couple) is
         tmp : Tri.T_vecteur_couple;
         decroissant : Integer;
         croissant : Integer;
      begin
         decroissant := vect.taille;
         croissant := 1;
         tmp.taille := 0;
         while decroissant >= 1 loop
            tmp.taille := tmp.taille +1;
            tmp.vecteur(croissant):= vect.vecteur(decroissant);
            croissant := croissant +1;
            decroissant := decroissant - 1;
         end loop;
         vect := tmp;
      end inverser_ordre_vecteur;

      vect_court_trie_ada : Tri.T_vecteur_couple;       -- Données produites par un package standard qui va servir de vérification
      vect_court_moyen_ada :Tri.T_vecteur_couple;
      vect_long_trie_ada : Tri.T_vecteur_couple;
      vect_long_moyen_ada : Tri.T_vecteur_couple;
   begin
      Put_line("---------------------------------------------------");
      Put_Line("DONNEES DES TESTS");
      Put_Line("Voici les vecteurs à trier : ");
      New_line;

      -- Copier les vecteurs à trier

      vect_court_trie_ada := vect_court_trie;
      vect_court_moyen_ada := vect_court_moyen;
      vect_long_trie_ada := vect_long_trie;
      vect_long_moyen_ada := vect_long_moyen;

      -- Afficher les vecteurs
      Put_Line("Vecteur de petite taille et déjà trié, vecteur_1");
      New_Line;
      New_Line;
      Afficher(vect_court_trie);
      New_Line;
      New_Line;
      Put_Line("Vecteur de petite taille en désordre, vecteur_2");
      New_Line;
      New_Line;
      Afficher(vect_court_moyen);
      New_Line;
      New_Line;
      Put_Line("Vecteur de grande taille déjà trié, vecteur_3");
      New_Line;
      New_Line;
      --Afficher(vect_long_trie);
      New_Line;
      New_Line;
      Put_Line("Vecteur de grande taille en désordre, vecteur_4");
      New_Line;
      New_Line;
      --Afficher(vect_long_moyen);               --! à décommenter si vecteur pas très long
      New_Line;
      New_Line;

      -- Trier ces vecteurs avec ADA
      tri_ada(vect_court_moyen_ada.vecteur);
      tri_ada(vect_long_trie_ada.vecteur);
      tri_ada(vect_long_trie_ada.vecteur);
      tri_ada(vect_long_moyen_ada.vecteur);

      inverser_ordre_vecteur(vect_court_trie_ada);


      Put_line("---------------------------------------------------");
      Put_Line("DEBUT DES TESTS");
      Tri.tri_tas(vect_court_trie);
      Put_line("Test avec le vecteur_1");
      New_line;
      Put_line("Tri par tas");
      Afficher(vect_court_trie);
      New_line;
      New_line;
      Put_line("Tri par ada");
      Afficher(vect_court_trie_ada);
      New_line;
      New_line;


      pragma assert (Egalite_vecteur_couple(vect_court_trie,vect_court_trie_ada));


      Tri.tri_tas(vect_court_moyen);
      Put_line("Test avec le vecteur_2");

      New_line;
      Afficher(vect_court_moyen);
      New_line;
      New_line;
      Afficher(vect_court_moyen_ada);
      New_line;
      New_line;


      pragma assert (Egalite_vecteur_couple(vect_court_moyen,vect_court_moyen_ada));

      Tri.tri_tas(vect_long_trie);
      Put_line("Test avec le vecteur_3");


      New_line;
      --Afficher(vect_long_trie);                -- vecteur potentiellement très logn donc non affiché
      New_line;
      New_line;
      --Afficher(vect_long_trie_ada);
      New_line;
      New_line;

      pragma assert (Egalite_vecteur_couple(vect_long_trie,vect_long_trie_ada));


      Tri.tri_tas(vect_long_moyen);
      Put_line("Test avec le vecteur_4");


      New_line;
      --Afficher(vect_long_moyen);
      New_line;
      New_line;
      --Afficher(vect_long_moyen_ada);
      New_line;
      New_line;
      pragma assert (Egalite_vecteur_couple(vect_long_moyen,vect_long_moyen_ada));


   end test_Tri_tas;


   vecteur_null : v_simple;                              -- Données de départ ( vecteur Pi dans le module principal)
   vect_court_trie  : v_simple;
   vect_court_moyen : v_simple;
   vect_long_trie : v_simple;
   vect_long_moyen : v_simple;

   vect_court_trie_couple : Tri.T_vecteur_couple;         -- Données de tests
   vect_court_moyen_couple : Tri.T_vecteur_couple;
   vect_long_trie_couple : Tri.T_vecteur_couple;
   vect_long_moyen_couple : Tri.T_vecteur_couple;



begin

   Donnees_test(vecteur_null,
                vect_court_trie,
                vect_court_moyen,
                vect_long_trie,
                vect_long_moyen);

   test_Initialiser_poids(
                          vect_court_trie,
                          vect_court_moyen,
                          vect_long_trie,
                          vect_long_moyen,
                          vect_court_trie_couple,         -- Données de tests
                          vect_court_moyen_couple,
                          vect_long_trie_couple,
                          vect_long_moyen_couple);

   test_Tri_tas(vect_court_trie_couple,vect_court_moyen_couple,vect_long_trie_couple,vect_long_moyen_couple);

   Put_Line("FIN DES TESTS");
end test_Tri_par_tas;
