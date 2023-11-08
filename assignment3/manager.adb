with Ada.Text_IO; use Ada.Text_IO;
with PasswordDatabase; use PasswordDatabase;
with PIN; use PIN;

package body manager is

    procedure get(DB : Database; s: String) is
    begin
        if Has_Password_For(DB,From_String(s)) = True and judge = False then
            Put_Line(To_String(Get(DB,From_String(s))));
            Put("unlocked> ");
        elsif judge = True then
            Put("locked>   ");
        else
            Put("unlocked> ");
        end if;
    end get;

    procedure rem_password(DB : in out Database; s : String) is
    begin
        if Has_Password_For(DB,From_String(s)) = True and judge = False then
            Remove(DB,From_String(s));
            Put("unlocked> ");
        elsif judge = True then
            Put("locked>   ");
        else
            Put("unlocked> ");
        end if;
    end rem_password;

    procedure put(DB : in out Database; s : String; s1 : String) is
    begin
        if judge = False then
            Put(DB,From_String(s),From_String(s1));
            Put("unlocked> ");
        else
            Put("locked>   ");
        end if;
    end put;

    procedure unlock(p : String) is
    begin
        if  PIN."="(PIN1,PIN.From_String(p)) and judge = True then
            judge := False;
            Put("unlocked> ");
        elsif judge = False then
            Put("unlocked> ");
        else
            Put("locked>   ");
        end if;
    end unlock;

    procedure lock(p : String) is
    begin
        if judge = False then
            PIN1 := PIN.From_String(p);
            Put("locked>   ");
            judge := True;
        else
            Put("locked>   ");
        end if;
    end lock;

end manager;