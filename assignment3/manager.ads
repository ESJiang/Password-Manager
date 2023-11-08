with PIN; use PIN;
with PasswordDatabase; use PasswordDatabase;
with Ada.Containers; use Ada.Containers;

package manager with SPARK_Mode is

    PIN1 : PIN.PIN := From_String("0000");
    judge : Boolean := False;

    procedure get(DB : Database; s : String)
    with Pre=>(s'Length<=Max_URL_Length);

    procedure rem_password(DB : in out Database; s : String)
    with Pre=>(s'Length<=Max_URL_Length),
    Post=>(if Has_Password_For(DB,From_String(s)) = True and judge'Old = False then Length(DB) = Length(DB'Old) - 1);

    procedure put(DB : in out Database; s : String; s1 : String)
    with Pre=>(s'Length<=Max_URL_Length and s1'Length<=Max_Password_Length),
    Post=>(if judge'Old = False then Length(DB) = Length(DB'Old) + 1);

    procedure unlock(p : String)
    with Pre => (p'Length = 4),
    post=> (if PIN."="(PIN1,From_String(p)) and judge'Old = True then judge = False);

    procedure lock(p : String)
    with Pre => (p'Length = 4),
    Post=>(if judge'Old = False then PIN1 = From_String(p) and judge = True);

end manager;