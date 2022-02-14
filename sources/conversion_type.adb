--with Ada.Text_IO; use Ada.Text_IO;

package body Conversion_Type is

   type ultra_precis is digits 16;        -- ce type va nous permettre d'avoir des réels avec une précision acceptable

   -- package Real_IO is new Ada.Text_IO.Float_IO(T_Element); use Real_IO;      utile pour du debugage

   function To_Integer( chaine : in Unbounded_String) return Integer is

      taille : Integer;         -- taille de la chaine de caractères rentrée
      chiffre : Integer;        -- chiffre converti en integer
      nombre : Integer;         -- chaine de caractère convertie en nombre

   begin
      -- Initialiser les variables
      taille := Length(chaine);
      nombre := 0;

      -- Appliquer le schéma de Horner pour reconstruire l'entier
      for indice in 1..taille loop

         -- Convertir chaine(indice) en chiffre
         chiffre:= Character'Pos(To_string(chaine)(indice)) - Character'Pos('0');

         -- Vérifier que c'est bien un chiffre !
         if chiffre > 9 or chiffre < 0 then
            raise Bad_Type_Conversion_Error;
         end if;

         -- Appliquer Horner
         nombre := nombre * 10 + Chiffre;
      end loop;

      return nombre;

   end To_Integer;

   function To_reel( chaine : in Unbounded_String) return T_Element is

      -- Nom : puissance_10
      -- Semantique : Renvoie la puissance de 10 négative associée à nombre
      -- Paramètre(s) :
      -- exposant : in Integer;                  -- exposant
      -- Type de retour : ultra_precis;          -- le retour s'écrit sur 16 digits !
      -- Pre : True
      -- Post : puissance_10'Result - puissance_10'Result < 0.000000000000001

      -- Tests :
      -- Entrée : 2                                    Sortie : environ 1.0000000000000000 E-02

      -- Exceptions : Exponant_Too_Big_error si l'utilisateur rentre un exposant plus grand que 16 (ada n'autorise que 16 digits au max)
      function puissance_10 (exposant : in Integer) return ultra_precis is
         resultat : ultra_precis;
         Exponant_Too_Big_error : exception;
      begin

         if exposant > 16 then               -- la précision du résultat ne serait pas assez bonne !
            raise Exponant_Too_Big_error;
         else
            resultat := ultra_precis(0.1);
            for i in 1..exposant-1 loop
               resultat := ultra_precis(0.1)*resultat;
            end loop;
            return resultat;
         end if;
      end puissance_10;


      taille_chaine : Integer;                     -- taille de la chaine de caractères rentrée
      chaine_partie_entiere : Unbounded_String;    -- partie entière du T_Element sous forme d'une chaine
      partie_entiere : Integer;                    -- partie entière du T_Element
      partie_decimal : T_Element;                  -- partie décimale du T_Element
      position_virgule : Integer;                  -- indice de la position occupée par la virgule
      virgule_trouvee : Boolean;                   -- Indique si la chaine comporte bien une virgule
      chaine_partie_decimal : Unbounded_String;    -- Chaine représentant la partie décimale
      taille_partie_decimal : Integer;             -- Taille de la chaine

   begin

      -- Traiter le cas évident ou la chaine est trop petite
      taille_chaine := Length(chaine);
      if taille_chaine < 3 then
         raise Bad_Type_Conversion_Error;

         -- Essayer de convertir la chaine en T_Element
      else

         -- Trouver la place de la virgule
         position_virgule := 1;
         virgule_trouvee := False;
         while not virgule_trouvee loop
            if To_string(chaine)(position_virgule) = '.' then
               virgule_trouvee :=  True;
            end if;
            position_virgule := position_virgule + 1 ;
         end loop ;
         position_virgule := position_virgule -1;     -- la sortie du while se fait avec position + 1

         -- Extraire la partie entière du nombre
         for i in 1..position_virgule-1 loop
            chaine_partie_entiere := chaine_partie_entiere & To_string(chaine)(i) ;
         end loop;

         -- Convertir la partie entière en T_Element
         partie_entiere := To_Integer(chaine_partie_entiere);

         -- Extraire la partie décimale
         chaine_partie_decimal := To_Unbounded_String(To_String(chaine)(position_virgule+1..Taille_chaine));
         taille_partie_decimal := Length(chaine_partie_decimal);

         -- Convertir la partie décimale
         if taille_partie_decimal <= 8 then              -- cette condition est due au fait que les réels <= 10⁸en ADA

            partie_decimal:= T_Element(To_Integer(chaine_partie_decimal));
            partie_decimal := partie_decimal*T_Element(puissance_10(taille_partie_decimal));
         else
            -- Découper la partie décimale en deux pour convertir des entiers de plus de 8 digits !
            partie_decimal := T_Element(To_Integer(To_Unbounded_String(To_String(chaine_partie_decimal)(1..8))));
            partie_decimal := partie_decimal*T_Element(puissance_10(8));     -- partie "gauche"
            partie_decimal := partie_decimal + T_Element(To_Integer(To_Unbounded_String(To_String(chaine_partie_decimal)(9..taille_partie_decimal))))*T_Element(puissance_10(taille_partie_decimal));
         end if;


         return partie_decimal + T_Element(partie_entiere);
      end if;
   end To_reel;


   procedure Integer_or_reel( chaine : in Unbounded_String; reel : out T_Element;
                              entier : out Integer; indicateur : out Character) is

   begin
      entier:= -1;
      -- Déterminer si c'est un réel
      begin
         reel := To_reel(chaine);
         indicateur := 'f';
      exception
         when Bad_Type_Conversion_Error|CONSTRAINT_ERROR =>    -- le constraint error apparait si on cherche la virgule dans un réel !
            -- Déterminer si c'est un entier
            begin
               entier := To_Integer(chaine);
               indicateur := 'i';
            exception
                  -- Déterminer si c'est autre choses
               when Bad_Type_Conversion_Error =>indicateur := 'o';
            end;
      end;
   end Integer_or_reel;

end Conversion_Type;
