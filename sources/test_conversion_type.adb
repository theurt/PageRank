-- Ce module permet de tester le module conversion_type.adb
with Conversion_Type;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Text_IO; use Ada.Text_IO;

procedure test_Conversion_Type is

   package conversion_float is new Conversion_Type(T_Element => float);
   use conversion_float;

   -- Tester la procedure de conversion en entier
   procedure test_To_Integer is
      useless : Integer;

   begin
      -- Test avec un entier long
      useless := To_Integer(To_Unbounded_String("10000"));
      pragma assert(useless=10000);

      -- Test avec 0
      pragma assert(To_Integer(To_Unbounded_String("0"))=0);

      -- Test avec un character
      begin
         useless := To_Integer(To_Unbounded_String("z"));
         pragma assert (False);
      exception
         when Bad_Type_Conversion_Error => pragma assert( True);
      end;

      -- Test avec un flottant
      begin
         useless := To_Integer(To_Unbounded_String("0.3"));
         pragma assert (False);
      exception
         when Bad_Type_Conversion_Error => pragma assert( True);
      end;
   end test_To_Integer;


   -- Tester la procedure de conversion en réel
   procedure test_To_reel is
      useless : float;

   begin

      -- Test avec un réel sur 10 digit
      useless := conversion_float.To_reel(To_Unbounded_String("0.85000002384"));
      pragma assert (useless=float(0.85000002384));

      -- Test avec un entier de taille 1
      begin
         useless := conversion_float.To_reel(To_Unbounded_String("3"));
         pragma assert (False);
      exception
         when Bad_Type_Conversion_Error => pragma assert( True);
      end;

      -- Test avec un entier de taille 2
      begin
         useless :=conversion_float.To_reel(To_Unbounded_String("33"));
         pragma assert (False);
      exception
         when Bad_Type_Conversion_Error => pragma assert( True);
      end;

      -- Test avec un flottant ne commençant pas par 0,...
      pragma assert (conversion_float.To_reel(To_Unbounded_String("1.3")) = float(1.3));

      -- Test avec un flottant compatible, attention le test d'égalité sur les float ne marchera pas car ada arrondit
      pragma assert (conversion_float.To_reel(To_Unbounded_String("0.009"))-float(0.009)<float(0.000001));

      -- Test avec 0
      begin
         useless :=conversion_float.To_reel(To_Unbounded_String("0"));
         pragma assert (False);
      exception
         when Bad_Type_Conversion_Error => pragma assert( True);
      end;

      -- Test avec un character
      begin
         useless :=conversion_float.To_reel(To_Unbounded_String("z"));
         pragma assert (False);
      exception
         when Bad_Type_Conversion_Error => pragma assert( True);
      end;

   end test_To_reel;

   -- Tester la procédure convertissant en entier ou réel avec sortie d'un indicateur sur le type produit
   procedure test_Integer_or_reel is

      indicateur_1 : Character;            -- indicateur du premier test
      indicateur_2 : Character;
      indicateur_3 : Character;
      indicateur_4 : Character;
      useless_reel : float;                -- valeur réellle produite mais non utilisée ici
      useless_integer : Integer;           -- valeur entière produite mais non utilisée ici
   begin
      -- Test avec un entier
      Integer_or_reel(To_Unbounded_String("99"),useless_reel,useless_integer,indicateur_1);
      pragma assert (indicateur_1 = 'i');

      -- Test avec un T_Element
      Integer_or_reel(To_Unbounded_String("0.3"),useless_reel,useless_integer,indicateur_2);
      pragma assert (indicateur_2 ='f');

      -- Test avec un flottant ne commençant pas par 0,...

      Integer_or_reel(To_Unbounded_String("1.3"),useless_reel,useless_integer,indicateur_3);
      pragma assert (indicateur_3 = 'f');

      -- Test avec un character

      Integer_or_reel(To_Unbounded_String("a"),useless_reel,useless_integer,indicateur_4);
      pragma assert (indicateur_4 ='o');

   end test_Integer_or_reel;

begin
   Put_Line("Test conversion des entiers");
   test_To_Integer;
   Put_Line("Test conversion en réel de précision variable");
   test_To_reel;
   Put_Line("Test indicateur du type");
   test_Integer_or_reel;
   Put_Line ("Fin des tests : OK.");
end test_Conversion_Type;
