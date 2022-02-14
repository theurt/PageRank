with Ada.IO_Exceptions;
with Ada.Text_IO; use Ada.Text_IO;
--with Ada.Float_Text_IO; use Ada.Float_Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Ada.Command_line; use Ada.Command_line;

--with Google_Naive;
with Conversion_Type;

package body Recuperation_Argument is


   procedure Recuperer_valeurs_option(alpha : out T_alpha;
                                      iteration : out Integer;
                                      naive : out Boolean;
                                      Nom_fichier : out Unbounded_String )is



      nb_max_argument : constant Integer := 6;         -- on tient compte de l'option naive ou non

      -- Nécessaire pour faire un get(T_alpha)
      package Real_IO is new Ada.Text_IO.Float_IO(T_alpha); use Real_IO;

      -- Utile pour récupérer les arguments dans un vecteur_ligne de chaine => on ne peut pas utiliser le module Google qui
      -- porte sur des matrices de réels
      type tableau_str is array(1..nb_max_argument) of Unbounded_String;

      type vecteur is
         record
            tableau : tableau_str;
            taille : Integer;                 -- { taille <= 6 and taille >0 }
         end record;

      type ultra_precis is digits 16;         -- permet d'écrire un alpha par défaut presque exact


      package conversion is new Conversion_Type(T_Element => T_alpha);
      use Conversion;

      -- Nom : Is_File_Name
      -- sémantique : Vérifier si un argument est le fichier en .net
      -- paramètres :
      -- chaine : in Unbounded_String;         -- argument à vérifier
      -- type de retour : Boolean
      -- Pre : True
      -- Post : True
      -- Tests :
      -- Entrée :  fichier.net ; Sortie : True
      -- Entrée : fichier      ; Sortie : False
      -- Exception : Aucune
      function Is_File_name(chaine : in Unbounded_String) return Boolean is

         taille : Integer;      -- taille de la chaine issue de la ligne de commande

      begin

         taille := length(chaine);
         if taille > 4 and then To_String(chaine)(taille-3..taille) = ".net" then
            return True;
         else
            return False;
         end if;
      end Is_File_name;


      -- Nom : Command_Line_Vectorisee
      -- sémantique : Transforme la ligne de commande en vecteur ligne
      -- paramètres :
      -- vect_arg : out vecteur;         -- vecteur consitué des arguments
      -- Pre : True
      -- Post : vect_arg.taille <= 6
      -- Tests :
      -- Entrée :  -P -I 120 -A 0.8 fichier.net ; Sortie : ["-P","-I","120","-A","0.8","fichier.net"]

      -- Exception : Aucune
      procedure Command_Line_Vectorisee(vect_arg : out vecteur) is
         N : Integer;
      begin
         N := Argument_Count;
         vect_arg.taille := N;

         for i in 1..N loop
            vect_arg.tableau(i) := To_Unbounded_String(Argument(i));
         end loop;

      end Command_Line_Vectorisee;

      -- Nom : Afficher_erreur
      -- sémantique : Afficher un message d'erreur et lever une exception pour aider l'utilisateur selon le code rentré
      -- paramètres :
      -- nombre : in Integer;         -- code d'erreur
      -- Pre : True
      -- Post : True
      -- Tests :
      -- Entrée :  1 ; Sortie : "Le format autorisé est : -P -I [integer] -A [T_alpha] filename.net"
      --
      --                          "L'exception et le message ci-dessous devraient vous aider ;)");
      --                          " Option inconnue "
      --                           raised RECUPERATION_ARGUMENT.INVALID_NAME_OPTION_ERROR : recuperation_argument.adb:112

      -- Exception : voir les exceptions ci-dessous
      procedure Afficher_erreur (nombre : in Integer ) is

      begin

         -- Afficher un message précisant le format
         New_line;
         Put("Le format autorisé est : -P -I [integer] -A [T_alpha] filename.net");
         New_Line;
         New_line;
         Put("L'exception et le message ci-dessous devraient vous aider ;)");
         New_Line;
         New_line;

         -- Afficher un message plus précis sur la cause de l'erreur
         case nombre is

         when 1
            =>Put("Option inconnue");
            raise Invalid_Name_Option_Error;

         when 2
            => Put(" Veuillez réesayer avec des valeurs valides pour les options");
            raise Invalid_Type_Arguments_Error;
         when 3
            => Put("Trop d'arguments !");
            raise Too_Many_Argument_Error;

         when 4
            => Put( "Vous avez oublié de préciser les options !");
            raise Missing_Options_Error;
         when 5
            => Put("Essayez avec un nom de fichier valide");
            raise File_Absent_Error;

         when 6
            => Put("il manque une valeur d'option");
            raise Missing_Arguments_Value_Error;

         when 7
            => Put( "Vous avez oublié de préciser le fichier");
            raise File_Absent_Error;

         when 8
            => Put("Pensez à rentrer un nom de fichier correct en .net");
            raise File_Absent_Error;

         when others => NUll;
         end case;
      end Afficher_erreur;


      -- Nom : Is_number_Arguments_Correct
      -- sémantique : Vérifier qu'il n'y a aucune erreur sur le nombre d'arguments
      -- paramètres :
      -- N : in Integer;                            -- nombre d'arguments
      -- nb_max_argument : in Integer;              -- nombre max théorique d'arguments
      -- Nom_fichier : out Unbounded_String;        -- nom éventellement récupéré du fichier
      -- nb_correct_argument : out Boolean;         -- le nombre d'argument était correct ?
      -- Pre : True
      -- Post : le nom de fichier finit en .net
      -- Tests :
      -- Entrée :  N = 7, nb_max_argument = 6 ; Sortie : Too_Many_Arguments
      -- Entrée : N = 5, nb_max_argument = 6 ;   Sortie nb_correct_argument = True et potentiellement Nom_fichier =... .net

      -- Exception : File_Absent_Error; Too_Many_Argument_Error
      procedure Is_number_Arguments_Correct ( N : in Integer;
                                              nb_max_argument : in Integer;
                                              Nom_fichier : out Unbounded_String;
                                              nb_correct_argument: out Boolean ) is
      begin


         if N = 0 then         -- Aucun argument rentré !

            Afficher_erreur(7);

         elsif N = 1 then

            -- Vérifier que c'est bien le fichier qui a été rentré comme argument unique

            if Is_file_name(To_Unbounded_String(Argument(1))) then
               Nom_fichier := To_Unbounded_String(Argument(1));
               nb_correct_argument := False;        -- ne plus chercher à récupérer d'autres arguments
            else
               Afficher_erreur(8);
            end if;

         elsif N > nb_max_argument then    -- trop d'argument
            Afficher_erreur(3);

         else
            nb_correct_argument := True;
         end if;

      end Is_number_Arguments_Correct;


      -- Nom : recuperer_chaque_option
      -- sémantique : Récupérer les valeurs des options I, A, P et le nom de fichier
      -- paramètres :
      -- N N : in Integer;
      -- vect_arg : in vecteur;
      -- iteration : out Integer;
      -- alpha : out T_alpha;
      -- naive :out Boolean;
      -- Nom_fichier : out Unbounded_String ;

      -- Pre : True
      -- Post : le nom de fichier finit en .net, alpha > 1 and alpha < 0 and iteration > 1

      -- Tests : Aucun
      -- Exception : voir sous-programme afficher_erreur pour la liste exhaustive
      procedure recuperer_chaque_option (N : in Integer;
                                         vect_arg : in vecteur;
                                         iteration : in out Integer;
                                         alpha : in out T_alpha;
                                         naive : in out Boolean;
                                         Nom_fichier : out Unbounded_String) is

         -- Nom : detecter_option
         -- sémantique : Marquer la lecture d'une option par un indicateur nommé option
         -- paramètres :
         -- vect_arg : in vecteur;              -- vecteur des arguments
         -- option : in out Character;
         -- i : in Integer;                     -- iteration courante
         -- type de retour : Character;

         -- Pre : True
         -- Post : detecter_option'Result = 'o' or detecter_option'Result = 'I' or detecter_option'Result = 'P'
         --                  or detecter_option'Result = 'A'

         -- Tests : Aucun
         -- Exception : voir sous-programme afficher_erreur avec code d'erreur 2, 1 et 6
         procedure detecter_option(vect_arg : in vecteur;i : in Integer; option : in out Character) is

         begin

            -- Y a-t-il une option valide ?
            if length(vect_arg.tableau(i)) /=2 then
               Afficher_erreur(2);
            else
               if option = 'o' then

                  -- Vérifier qu'une option est possible
                  case To_String(vect_arg.tableau(i))(2) is
                  when 'I' => option :=  'I';
                  when 'A' => option :='A';
                  when 'P' =>
                     option := 'o';
                     naive := True;
                  when others =>  Afficher_erreur(1);

                  end case;
               else
                  Afficher_erreur(6);
               end if;
            end if;
         end detecter_option;


         -- Nom : Rentrer_alpha
         -- sémantique : Obtenir un alpha compatible
         -- paramètres :
         -- alpha : out T_alpha;
         -- nombre_reel : in T_alpha;                 -- valeur potentielle de alpha
         -- indicateur_type : in Character;          -- type de l'argument courant
         -- option : in Character;                   -- option rencontrée ?
         -- Pre : True
         -- Post : alpha > T_alpha(1) and alpha < T_alpha(0) and option = 'o'

         -- Tests : Aucun
         -- Exception : voir sous-programme afficher_erreur avec code d'erreur 2 et 1
         procedure Rentrer_alpha(alpha : in out T_alpha;
                                 nombre_reel : in T_alpha;
                                 indicateur_type : in Character;
                                 option : in out Character) is

         begin

            if indicateur_type /= 'f' then        -- erreur sur le type de alpha
               Afficher_erreur(2);
            else
               alpha := nombre_reel;

               -- Demander une saisie robuste entre 0 et 1
               while alpha > T_alpha(1) or alpha < T_alpha(0) loop
                  begin
                     -- Donner la consigne
                     Put(" Alpha doit être compris entre 1 et 0 svp : ");
                     Real_IO.Get(alpha);
                     Skip_Line;
                  exception
                     when ADA.IO_EXCEPTIONS.DATA_ERROR => Skip_Line;     -- SI l'utilisateur ne rentre même pas un réel !
                  end;
               end loop;
            end if;
            New_line;
            option := 'o';     -- l'option a été consommée
         end Rentrer_alpha;


         -- Nom : Rentrer_iteration
         -- sémantique : Obtenir une valeur d'iteration compatible
         -- paramètres :
         -- iteration : out Integer;
         -- nombre_reel : in Integer;                 -- valeur potentielle de iteration
         -- indicateur_type : in Character;          -- type de l'argument courant
         -- option : in Character;                   -- option rencontrée ?
         -- Pre : True
         -- Post : iteration > 0 and option = 'o'

         -- Tests : Aucun
         -- Exception : voir sous-programme afficher_erreur avec code d'erreur 2 et 1
         procedure Rentrer_iteration(iteration : in out Integer;
                                     nombre_entier : in Integer;
                                     indicateur_type : in Character;
                                     option : in out Character) is

         begin

            if indicateur_type /= 'i' then      -- erreur sur le type de iteration
               Afficher_erreur(2);
            else
               iteration := nombre_entier;
               -- Demander une valeur d'iteration > 0
               while iteration <= 0 loop
                  begin
                     Put(" iteration doit être plus grand que 1 svp : ");
                     Get(iteration);
                     Skip_Line;
                  exception
                     when ADA.IO_EXCEPTIONS.DATA_ERROR =>Skip_Line;     -- SI l'utilisateur ne rentre même pas un entier !
                  end;
               end loop;
               New_line;
               option := 'o';
            end if;
         end Rentrer_iteration;


         -- Nom : Vérification_fichier
         -- sémantique : Vérifier quelques cas d'erreur
         -- paramètres :
         -- i : out Integer;                          -- iteration courante
         -- N : in Integer;                           -- nombre d'argument
         -- vect_arg : in vecteur;                    -- vecteur des arguments
         -- Nom_fichier : out Unbounded_String;       -- nom du fichier
         -- Pre : True
         -- Post : Is_File_Name(vect_arg(i))

         -- Tests : Aucun
         -- Exception : voir sous-programme afficher_erreur avec code d'erreur 3,4 et 5
         procedure Verification_fichier(i : in Integer;
                                        N : in Integer;
                                        vect_arg : in vecteur;
                                        Nom_fichier : out Unbounded_String) is

         begin

            if Is_File_Name(vect_arg.tableau(i)) and i/=N then          -- l'utilisateur a rentré le fichier + autre chose
               Afficher_erreur(3);

            elsif Is_File_Name(vect_arg.tableau(i)) and i=N then        -- on est arrivé jusqu'au nom de fichier
               Nom_Fichier := vect_arg.tableau(i);

            elsif not Is_File_Name(vect_arg.tableau(i)) and i/=N then
               Afficher_erreur(4);

            else
               Afficher_erreur(5);               -- le nom de fichier a été oublié ( exception aussi levée par un nom de fichier incorrect)
            end if;

         end Verification_fichier;

         option : Character;                -- indique si un argument figure parmi les options
         indicateur_type : Character;       -- donne le type d'un argument
         nombre_entier : Integer;           -- conversion de la chaine iteration en l'entier associé
         nombre_reel : T_alpha;             -- conversion de la chaine alpha en le réeel associé
      begin

         option := 'o';                  -- par défaut aucune option valide n'est détectée
         for i in 1..N loop

            if To_String(vect_arg.tableau(i))(1)='-' then      -- l'argument commence par un tiret
               -- Détecter les options
               Detecter_option(vect_arg,i,option);

               -- Récupérer les valeurs des options/le nom de fichier
            else
               if Is_File_name(vect_arg.tableau(i)) and option = 'o' then    -- aucune option
                  Nom_fichier:= vect_arg.tableau(i);
               else
                  -- Vérifier si c'est un T_alpha ou un integer
                  nombre_entier := -1;
                  nombre_reel := 2.0;
                  Integer_or_reel(vect_arg.tableau(i),nombre_reel,nombre_entier, indicateur_type);

                  case option is
                  when 'A' =>
                     -- Récupérer alpha
                     Rentrer_alpha(alpha,nombre_reel,indicateur_type,option);
                  when 'I' =>
                     -- Récupérer iteration
                     Rentrer_iteration(iteration,nombre_entier,indicateur_type,option);

                  when others =>
                     -- Faire des vérifications sur le nom de fichier
                     Verification_fichier(i,N,vect_arg,Nom_fichier);
                  end case;
               end if;
            end if;
         end loop;

         -- Options oubliées
         if option /= 'o' then
            Afficher_erreur(6);
         end if;

         -- Nom de fichier  oublié
         if not Is_File_name(vect_arg.tableau(N)) then
            Afficher_erreur(7);
         end if;
      end recuperer_chaque_option;


      N : Integer;                               -- nombre d'arguments donnés en ligne de commande
      it_defaut : constant Integer := 150;       -- nombre d'iteration par défaut
      alpha_defaut : constant T_alpha := T_alpha(ultra_precis(0.85));   -- alpha par défaut
      vect_arg : vecteur;                         -- vecteur des arguments
      nb_arg_correct : Boolean;                   -- indique si le nombre d'arguement est correct

   begin

      -- Récupérer le nombre d'arguments de la ligne de commande
      N := Argument_Count;

      -- Initialiser les valeurs par défaut de iteration et alpha
      iteration := it_defaut;
      alpha:= alpha_defaut;
      naive := False;

      -- Détecter les erreurs éventuelles dues au nombre d'arguments
      Is_number_Arguments_Correct(N, nb_max_argument, Nom_fichier, nb_arg_correct);


      -- Récupérer les valeurs d'options
      if nb_arg_correct then       -- Si le seul argument est le nom du fichier, ce if est ignoré

         -- Récupérer tous les arguments dans un vecteur ligne
         Command_Line_Vectorisee(vect_arg);

         -- Récupérer uniquement les valeurs des options et le nom de fichier
         recuperer_chaque_option(N,vect_arg,iteration,alpha,naive,Nom_fichier);

      end if;
   end Recuperer_valeurs_option;

end Recuperation_Argument;
