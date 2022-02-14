with Ada.Text_IO;           use Ada.Text_IO;

package body Google_Naive is

   procedure Initialiser (matrice : out T_Google_Naive; dimensions_ligne : in Integer; dimensions_colonne : in Integer) is

   begin
      matrice.nb_ligne := dimensions_ligne;
      matrice.nb_colonne := dimensions_colonne;
   end Initialiser;



   function Est_Vide (Matrice : in T_Google_Naive) return Boolean is

   begin
      return (matrice.nb_ligne = 0 and matrice.nb_colonne = 0) ;
   end Est_Vide;



   procedure Dimension(Matrice : in T_Google_Naive; ligne : out Integer; colonne : out Integer) is

   begin
      ligne := matrice.nb_ligne;
      colonne := matrice.nb_colonne;
   end Dimension;



   function Get_coefficient (Matrice : in T_Google_Naive; ligne : in Integer; colonne : in Integer) return T_Element is

   begin
      if ligne > Matrice.nb_ligne or colonne > Matrice.nb_colonne then         -- dimensions incompatibles
         raise Invalid_indices_Error;
      else
         return Matrice.tableau(ligne,colonne);
      end if;
   end Get_coefficient;



   procedure Enregistrer_coefficient (Matrice : in out  T_Google_Naive; ligne : in Integer; colonne : in Integer; coefficient : in T_Element) is

   begin
      if matrice.nb_colonne < colonne or matrice.nb_ligne < ligne then         -- dimensions incompatibles
         raise Dimensions_incompatibles_Error;
      else
         Matrice.tableau(ligne,colonne) := coefficient;
      end if;
   end Enregistrer_coefficient;



   function Somme (Matrice_A : in T_Google_Naive; Matrice_B : in T_Google_Naive) return T_Google_Naive is

      coefficient: T_Element;               -- A(i,j) + B(i,j)
      nb_ligne_A : Integer;                 -- nombre de ligne de la matrice A
      nb_ligne_B : Integer;                 -- nombre de ligne de la matrice B
      nb_colonne_A : Integer;               -- nombre de ligne de la matrice A
      nb_colonne_B : Integer;               -- nombre de ligne de la matrice B

      Matrice_C : T_Google_Naive;

   begin
      Dimension(Matrice_A,nb_ligne_A,nb_colonne_A);
      Dimension(Matrice_B,nb_ligne_B,nb_colonne_B);

      -- Vérifier que les matrices soient de dimensions compatibles
      if nb_ligne_A /= nb_ligne_B or nb_colonne_A /= nb_colonne_B then

         raise Dimensions_incompatibles_Error;


      else
         Initialiser(Matrice_C,nb_ligne_A,nb_colonne_A);          -- C stocke le resultat de la somme
         -- Sommer coefficient par coefficient
         for ligne in 1..nb_ligne_A loop
            coefficient := T_Element(0.0);
            for colonne in 1..nb_colonne_A loop
               coefficient := Matrice_A.tableau(ligne,colonne) + Matrice_B.tableau(ligne,colonne);
               Matrice_C.tableau(ligne,colonne) := coefficient;
            end loop;
         end loop;
      end if;

      return Matrice_C;
   end Somme;



   function Produit_matrices (Matrice_A : in T_Google_Naive; Matrice_B : in T_Google_Naive) return T_Google_Naive is

      somme: T_Element;                     -- A(i,j) + B(i,j)
      nb_ligne_A : Integer;                 -- nombre de ligne de la matrice A
      nb_ligne_B : Integer;                 -- nombre de ligne de la matrice B
      nb_colonne_A : Integer;               -- nombre de ligne de la matrice A
      nb_colonne_B : Integer;               -- nombre de ligne de la matrice B

      Matrice_C : T_Google_Naive;

   begin

      Dimension(Matrice_A,nb_ligne_A,nb_colonne_A);
      Dimension(Matrice_B,nb_ligne_B,nb_colonne_B);

      -- Vérifier que les matrices soient de dimensions compatibles
      if nb_colonne_A /= nb_ligne_B then

         raise Dimensions_incompatibles_Error;

      else
         Initialiser(Matrice_C,Matrice_A.nb_ligne,Matrice_B.nb_colonne);
         -- Enregistrer chaque coefficient
         for ligne in 1..Matrice_A.nb_ligne loop
            for colonne in 1..Matrice_B.nb_colonne loop

               -- Sommer les A(i,k) * B (k,j)
               somme := T_Element(0.0);
               for k in 1..Matrice_B.Nb_ligne loop
                  somme := somme + Get_coefficient(Matrice_A,ligne,k)* Get_coefficient(Matrice_B,k,colonne);
               end loop;
               Enregistrer_coefficient(Matrice_C,ligne,colonne,somme);
            end loop;
         end loop;

      end if;
      return Matrice_C;
   end Produit_matrices;


   procedure Produit_scalaire_matrice(Matrice : in out T_Google_Naive; scalaire : in T_Element) is

   begin
      for ligne in 1..Matrice.nb_ligne loop
         for colonne in 1..Matrice.nb_colonne loop
            Matrice.tableau(ligne,colonne):=scalaire*Matrice.tableau(ligne,colonne);
         end loop;
      end loop;
   end Produit_scalaire_matrice;





   function Egalite(Matrice_A : in T_Google_Naive; Matrice_B : in T_Google_Naive) return Boolean is

   begin
      if Matrice_B.nb_colonne /= Matrice_A.nb_colonne or Matrice_A.nb_ligne/= Matrice_B.nb_ligne then -- dimensions incompatibles

         return False;
      else
         -- Vérifier que les cofficients soient tous égaux
         for ligne in 1..Matrice_A.nb_ligne loop
            for colonne in 1..Matrice_A.nb_colonne loop
               if Matrice_A.tableau(ligne,colonne) /= Matrice_B.tableau(ligne,colonne) then
                  return False;
               end if;
            end loop;
         end loop;
         return True;
      end if;
   end Egalite;



   procedure Affecter (Matrice_A : in out T_Google_Naive; Matrice_B : in T_Google_Naive) is

   begin

      -- Vérifier que les matrices soient de dimensions compatibles
      if Matrice_B.nb_colonne /= Matrice_A.nb_colonne or Matrice_A.nb_ligne/= Matrice_B.nb_ligne then

         raise Dimensions_incompatibles_Error;
      else
	 -- Affecter coefficient par coefficient
         for ligne in 1..Matrice_B.nb_ligne loop
            for colonne in 1..Matrice_B.nb_colonne loop
               Matrice_A.tableau(ligne,colonne) := Matrice_B.tableau(ligne,colonne);
            end loop;
         end loop;
      end if;
   end Affecter;




   procedure Affichage (Matrice : in T_Google_Naive) is

   begin


      if Matrice.nb_colonne=0 or matrice.nb_ligne=0 then
         -- Afficher la matrice vide
         Put("[ ]");
      else
         Put('[');
         -- Afficher coefficient par coefficient
         for ligne in 1..Matrice.nb_ligne loop
            Put('[');
            for colonne in 1..Matrice.nb_colonne loop
               Afficher(Matrice.tableau(ligne,colonne));
               Put(',');

            end loop;
            Put(']');
            New_Line;
         end loop;
         Put(']');
      end if;
   end Affichage;

end Google_Naive;
