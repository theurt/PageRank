with Ada.Text_IO;           use Ada.Text_IO;
with Ada.Float_Text_IO;   use Ada.Float_Text_IO;
with Ada.Integer_Text_IO;   use Ada.Integer_Text_IO;

package body Tri_par_tas is

   procedure Afficher (tas : in T_vecteur_couple) is
   begin
      Put('[');
      for i in 1..tas.taille loop
         Put("( ");
         Put(tas.vecteur(i).indice,0);
         Put(" : ");
         Put(Float(tas.vecteur(i).weight),0);
         Put(", )");
      end loop;
      Put(']');
   end Afficher;


   procedure Initialiser_poids(vecteur_ligne : in P_Google_Naive.T_Google_Naive; poids: out T_vecteur_couple) is
      ligne, colonne : Integer;
   begin
      -- Initialiser le vecteur poids
      P_Google_Naive.Dimension(vecteur_ligne, ligne, colonne);
      poids.taille := 0;
      -- Associer à chaque coefficient un couple (indice : poids)
      for i in 1..colonne loop
         poids.vecteur(i).indice := i-1;
         poids.vecteur(i).weight := P_Google_Naive.Get_coefficient(vecteur_ligne,ligne,i);
         poids.taille := poids.taille +1;
      end loop;
   end Initialiser_poids;

   -- Nom : Permuter
   -- Semantique : Permuter deux éléments dans un tas
   -- Paramètre(s) :
   -- tas : in out vecteur_double.T_Google_Naive;                       -- tas ou l'on cherche à permuter
   -- indice_1 : in Integer;                                             -- indice de l'élément 1 à permuter
   -- idnice_2 : in Integer;
   -- Pre : True
   -- Post : tas.vecteur(indice_1)'Before = tas.vecteur(indice_2)'After and tas.vecteur(indice_2)'Before = tas.vecteur(indice_1)'After

   -- Tests :
   -- Entrée : tas = [2,3,4], indice_1 = 1, indice_2 = 2 ;     Sortie : [3,2,4]

   -- Exception : Empty_tas_Error
   procedure permuter(tas : in out T_vecteur_couple; indice_1 : in Integer; indice_2 : in Integer) is
      tmp : T_couple;               -- variable stockant la valeur échangée
   begin

      if tas.taille < 2 then     -- Vérifier qu'il y au moins deux variables dans le tas
         raise Empty_tas_error;
      else
         tmp := tas.vecteur(indice_1);
         tas.vecteur(indice_1) := tas.vecteur(indice_2);
         tas.vecteur(indice_2):=tmp;

      end if;
   end permuter;

   procedure Tri_tas (poids : in out T_vecteur_couple) is

      -- Nom : Ajouter
      -- Semantique : Ajouter à un tas (représenté sous la forme d'un tableau) un élément x en maintenant l'équilibre du tas
      -- Paramètre(s) :
      -- tas : in out vecteur_double.T_Google_Creuse;                       -- tas ou l'on cherche à ajouter
      -- x : in T_Couple;          -- element que l'on veut ajouter
      -- Pre : True
      -- Post : condition complexe à exprimer mais ne noeud père de x doit être plus petit que x !

      -- Tests :
      -- Entrée : tas = [2,3,4], x = 5 ;     Sortie : [2,3,4,5]
      -- Entrée : tas = [2,3,4], x = 1 ;     Sortie : [1,2,3,4,5]
      -- Exception : Full_tas_Error
      procedure Ajouter (tas : in out T_vecteur_couple; x : in T_couple) is

         j : Integer;         -- indice qui va nous permettre de parcourir le tas

      begin

         if tas.taille = nb_col then
            raise Full_tas_error;

         elsif tas.taille = 0 then                                   -- le tas est vide
            tas.vecteur(1):= x;
            tas.taille := tas.taille +1;
         else
            -- Initialiser j au dernier indice du "tas"
            j := tas.taille;

            -- Ajouter l'élément x à la dernière "feuille" du tas
            tas.vecteur(tas.taille+1):= x;
            tas.taille := tas.taille+1;

            -- Rééquilibrer le tas en effectuant des permutations entre x et son noeud père
            while j>1 and then tas.vecteur(j).weight <                -- on est pas arrivé à la racine et le fils est inférieur à son père
              tas.vecteur(Integer(j/2)).weight loop

               -- Permuter le noeud fils et le noeud père
               permuter(tas, j,j/2);

               -- Remonter d'un noeud
               j := j/2;
            end loop;
         end if;
      end Ajouter;

      -- Nom : Extraire_min
      -- Semantique : Retirer le min du tas et le rééquilibrer
      -- Paramètre(s) :
      -- tas : in out vecteur_double.T_Google_Creuse;                       -- tas ou l'on cherche à extraire
      -- Pre : Tas non vide
      -- Post : trop complexe pour être formulé !

      -- Tests :
      -- Entrée : tas vide () ;     Sortie : Empty_tas_error
      -- Entrée : [1,2,3,4,5] ;     Sortie : tas = [2,4,3,5] et return 1
      -- Exception : Empty_tas_error
      function Extraire_min(tas : in out T_vecteur_couple) return T_couple is

         minimum : T_couple;                 --Racine du tas
         j : Integer;                        -- indice de l'élément
         i : Integer;
      begin

         case tas.taille is

         when 0 => raise Empty_tas_error;     -- tas vide

         when 1      -- tas simple
            => tas.taille := tas.taille -1;
            minimum := tas.vecteur(1);


         when  2 =>
            -- Rééquilibrer un tas de taille 1
            minimum := tas.vecteur(1);
            tas.vecteur(1) := tas.vecteur(2);
            tas.taille := tas.taille -1 ;

         when 3 =>
            minimum := tas.vecteur(1);
            -- Rééquilibrer un tas de taille 2
            if tas.vecteur(2).weight > tas.vecteur(3).weight then
               tas.vecteur(1) := tas.vecteur(3);
            else
               tas.vecteur(1) := tas.vecteur(2);
               tas.vecteur(2) := tas.vecteur (3);
            end if;
            tas.taille := tas.taille - 1 ;

         when others =>
            -- Extraire le minimum (qui n'est autre que la racine du tas par construction du tas)
            minimum := tas.vecteur(1);
            tas.vecteur(1):= tas.vecteur(tas.taille);
            tas.taille := tas.taille - 1;

            -- Rééquilibrer le tas
            j := 1;

            while j<= tas.taille/2 loop                        -- quand la condition devient fausse, On est au bout du tas, le noeud j esst bien placé !

               --Chercher l'indice i du plus petit des descendants du noeud j
               if 2* j = tas.taille or tas.vecteur(2*j).weight < tas.vecteur(2*j+1).weight then -- On est au bout ou le noeud fils est inférieur
                  i := 2*j;      -- noeud gauche
               else
                  i := 2*j +1;   -- noeud droit
               end if;

               -- Echanger si le noeud fils est plus petit !
               if tas.vecteur(j).weight > tas.vecteur(i).weight then

                  permuter(tas,j,i);

                  j := i;

               else
                  j := tas.taille;
               end if;
            end loop;
         end case;
         return minimum;
      end Extraire_min;

      tas : T_vecteur_couple;                -- tas servant au tri
      len : Integer;                         -- taille du vecteur à trier
   begin
      tas.taille := 0;
      len := poids.taille;

      -- Créer le tas minimum
      while tas.taille < len loop

         -- Ajouter tous les éléments de poids un par un en équilibrant à chaque fois
         Ajouter(tas,poids.vecteur(tas.taille+1));
      end loop;

      -- Récupérer le minimum et le ranger à la fin de poids pour obtenir un ordre décroissant des poids
      while tas.taille >=1 loop
         poids.vecteur(tas.taille):=Extraire_min(tas);
      end loop;
   end Tri_tas;

end Tri_par_tas;
