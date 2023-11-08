-- student username1: fangweij , student ID: 971196
-- student username2: kennyl2 , student ID: 801361

-- Task four part one:
-- In order to satisfy the 3 security properties that the assignment given,
-- our group decided to add other determine statements to our previous implementation of task two.

-- Security property one: The Get, Put, Remove and Lock operations can only ever be performed when the password manager is in the unlocked state.

-- We initialize a Boolean variable in manager.ads called judge to represent the system state(lock/unlock), the initial value is false(judge: Boolean := False;).
-- False basically means the system is unlocked. If user enter lock command with a valid PIN, the value of judge will change to True.
-- Therefore, we can examine everytime if the variable judge is true or not. If it is True, then get, put, remove, lock function will do nothing(return;).


-- Security property two: The Unlock operation can only ever be performed when the password manager is in the locked state.

-- We can check if the judge=True. If so, the unlock operation can be executed when the PIN number provided is identical. Otherwise, the unlock operation will no do nothing.
-- Do nothing indicates 2 scenarios: 1. the system is in unlock state(judge=False) 2. The system is in locked state but the PIN number you given cannot match the master PIN system stored previously.


-- Security property three: The Lock operation, when it is performed, should update the master PIN with the new PIN that is supplied.

-- We initalize a variable called PIN1 to represent master PIN in manager.ads(PIN1 : PIN.PIN:=PIN.From_String("0000");).
-- Then we add "PIN1:=PIN.From_String(p);" to our lock procedure function in manager.adb.
-- Whenever judge=false(unlock state), the system will execute this code and assign new value to PIN1(update master PIN).
-- Therefore, the user need to enter the latest PIN in order to pass the authentication test(lock - unlock).


-- Task four part two:
-- We added spark annotations(preconditions and postcondions) in our manager.ads to specified the above three security properties.

-- for get procedure, the preconditon will be the url length should be less than the maximum size(1024).
-- with Pre=>(s'Length<=Max_URL_Length);

-- for rem procedure, the precondition will be the url length should be less than the maximum size(1024),
-- the postcondition will be the number of mapping in the database should be decreased by 1 after removing if the system is unlocked and the mapping can be found.
-- with Pre=>(s'Length<=Max_URL_Length), Post=>(if Has_Password_For(DB,From_String(s)) = True and judge'Old = False then Length(DB) = Length(DB'Old) - 1);

-- for put procedure, the precondtion will be the url length should be less that the maximum size(1024) and the password length should be less than the maximum size(100),
-- The postcondition will be the number of mapping in the database should be increased by 1 after putting if the system is unlocked.
-- with Pre=>(s'Length<=Max_URL_Length and s1'Length<=Max_Password_Length), Post=>(if judge'Old = False then Length(DB) = Length(DB'Old) + 1);

-- for unlock procedure, the precondition will be the length of PIN equals to 4. The postcondition will be the judge is changed to False if the PIN is same.
-- "with Pre => (p'Length = 4), post=> (if PIN."="(PIN1,From_String(p)) and judge'Old = True then judge = False);"

-- for lock procedure, the precondition will be the length of PIN equals to 4. The postcondition will be the judge is changed to True if the previous system stae is unlocked(judge=False).
-- "with Pre => (p'Length = 4), Post=>(if judge'Old = False then PIN1 = From_String(p) and judge = True);"

with PasswordDatabase; use PasswordDatabase;
with MyCommandLine; use MyCommandLine;
with MyString;
with MyStringTokeniser; use MyStringTokeniser;
with PIN; use PIN;
with manager; use manager;
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Ada.Strings; use Ada.Strings;
with Ada.Strings.Fixed; use Ada.Strings.Fixed;

procedure Main with SPARK_Mode is
    D : PasswordDatabase.Database;
    package Lines is new MyString(Max_MyString_Length => 2048);
    S  : Lines.MyString;
    T : MyStringTokeniser.TokenArray(1..3) := (others => (Start => 1, Length => 0));
    NumTokens : Natural;
begin
    if(Argument_Count /= 1) then
        Put("The number of argument is not equal to 1");
        return;
    elsif (Argument(1)'Length /= 4) then
        Put("The length of master PIN is not equal to 4");
        return;
    else
        if (Argument(1)(Argument(1)'First) < '0' or Argument(1)(Argument(1)'First) > '9') then
            return;
        elsif (Argument(1)(Argument(1)'First+1) < '0' or Argument(1)(Argument(1)'First+1) > '9') then
            return;
        elsif (Argument(1)(Argument(1)'First+2) < '0' or Argument(1)(Argument(1)'First+2) > '9') then
            return;
        elsif (Argument(1)(Argument(1)'Last) < '0' or Argument(1)(Argument(1)'Last) > '9') then
            return;
        else
            lock(p=>Argument(1));
        end if;
    end if;
    Init(D);
    loop
        Lines.Get_Line(S);
        S:= Lines.From_String(Trim(Lines.To_String(S), Right));
        Tokenise(Lines.To_String(S),T,NumTokens);
        if( NumTokens = 0 or NumTokens > 3) then
            Put("The number of tokens is out of range");
            return;
        elsif Lines.To_String(Lines.Substring(S,T(1).Start,T(1).Start+T(1).Length-1))="unlock" and NumTokens=2 then
            if (Lines.To_String(Lines.Substring(S,T(2).Start,T(2).Start+T(2).Length-1))'Length /= 4) then
                Put("The length of master PIN is not equal to 4");
                return;
            else
                if (Lines.To_String(Lines.Substring(S,T(2).Start,T(2).Start+T(2).Length-1))(Lines.To_String(Lines.Substring(S,T(2).Start,T(2).Start+T(2).Length-1))'First) < '0' or Lines.To_String(Lines.Substring(S,T(2).Start,T(2).Start+T(2).Length-1))(Lines.To_String(Lines.Substring(S,T(2).Start,T(2).Start+T(2).Length-1))'First) > '9') then
                    return;
                elsif (Lines.To_String(Lines.Substring(S,T(2).Start,T(2).Start+T(2).Length-1))(Lines.To_String(Lines.Substring(S,T(2).Start,T(2).Start+T(2).Length-1))'First+1) < '0' or Lines.To_String(Lines.Substring(S,T(2).Start,T(2).Start+T(2).Length-1))(Lines.To_String(Lines.Substring(S,T(2).Start,T(2).Start+T(2).Length-1))'First+1) > '9') then
                    return;
                elsif (Lines.To_String(Lines.Substring(S,T(2).Start,T(2).Start+T(2).Length-1))(Lines.To_String(Lines.Substring(S,T(2).Start,T(2).Start+T(2).Length-1))'First+2) < '0' or Lines.To_String(Lines.Substring(S,T(2).Start,T(2).Start+T(2).Length-1))(Lines.To_String(Lines.Substring(S,T(2).Start,T(2).Start+T(2).Length-1))'First+2) > '9') then
                    return;
                elsif (Lines.To_String(Lines.Substring(S,T(2).Start,T(2).Start+T(2).Length-1))(Lines.To_String(Lines.Substring(S,T(2).Start,T(2).Start+T(2).Length-1))'Last) < '0' or Lines.To_String(Lines.Substring(S,T(2).Start,T(2).Start+T(2).Length-1))(Lines.To_String(Lines.Substring(S,T(2).Start,T(2).Start+T(2).Length-1))'Last) > '9') then
                    return;
                else
                    unlock(p=>Lines.To_String(Lines.Substring(S,T(2).Start,T(2).Start+T(2).Length-1)));
                end if;
            end if;
        elsif Lines.To_String(Lines.Substring(S,T(1).Start,T(1).Start+T(1).Length-1))="lock" and NumTokens=2 then
            if (Lines.To_String(Lines.Substring(S,T(2).Start,T(2).Start+T(2).Length-1))'Length /= 4) then
                Put("The length of master PIN is not equal to 4");
                return;
            else
                if (Lines.To_String(Lines.Substring(S,T(2).Start,T(2).Start+T(2).Length-1))(Lines.To_String(Lines.Substring(S,T(2).Start,T(2).Start+T(2).Length-1))'First) < '0' or Lines.To_String(Lines.Substring(S,T(2).Start,T(2).Start+T(2).Length-1))(Lines.To_String(Lines.Substring(S,T(2).Start,T(2).Start+T(2).Length-1))'First) > '9') then
                    return;
                elsif (Lines.To_String(Lines.Substring(S,T(2).Start,T(2).Start+T(2).Length-1))(Lines.To_String(Lines.Substring(S,T(2).Start,T(2).Start+T(2).Length-1))'First+1) < '0' or Lines.To_String(Lines.Substring(S,T(2).Start,T(2).Start+T(2).Length-1))(Lines.To_String(Lines.Substring(S,T(2).Start,T(2).Start+T(2).Length-1))'First+1) > '9') then
                    return;
                elsif (Lines.To_String(Lines.Substring(S,T(2).Start,T(2).Start+T(2).Length-1))(Lines.To_String(Lines.Substring(S,T(2).Start,T(2).Start+T(2).Length-1))'First+2) < '0' or Lines.To_String(Lines.Substring(S,T(2).Start,T(2).Start+T(2).Length-1))(Lines.To_String(Lines.Substring(S,T(2).Start,T(2).Start+T(2).Length-1))'First+2) > '9') then
                    return;
                elsif (Lines.To_String(Lines.Substring(S,T(2).Start,T(2).Start+T(2).Length-1))(Lines.To_String(Lines.Substring(S,T(2).Start,T(2).Start+T(2).Length-1))'Last) < '0' or Lines.To_String(Lines.Substring(S,T(2).Start,T(2).Start+T(2).Length-1))(Lines.To_String(Lines.Substring(S,T(2).Start,T(2).Start+T(2).Length-1))'Last) > '9') then
                    return;
                else
                    lock(p=>Lines.To_String(Lines.Substring(S,T(2).Start,T(2).Start+T(2).Length-1)));
                end if;
            end if;
        elsif Lines.To_String(Lines.Substring(S,T(1).Start,T(1).Start+T(1).Length-1))="put" then
            if NumTokens/=3 then
                Put("invalid number of tokens of put procedure");
                return;
            else
                if Lines.To_String(Lines.Substring(S,T(2).Start,T(2).Start+T(2).Length-1))'Length > Max_URL_Length then
                    Put("the url length is invalid");
                    return;
                elsif Lines.To_String(Lines.Substring(S,T(3).Start,T(3).Start+T(3).Length-1))'Length>Max_Password_Length then
                    Put("the password length is invalid");
                    return;
                else
                    put(DB=>D,s=>Lines.To_String(Lines.Substring(S,T(2).Start,T(2).Start+T(2).Length-1)),s1=>Lines.To_String(Lines.Substring(S,T(3).Start,T(3).Start+T(3).Length-1)));
                end if;
            end if;
        elsif Lines.To_String(Lines.Substring(S,T(1).Start,T(1).Start+T(1).Length-1))="get" then
            if NumTokens/=2 then
                Put("invalid number of tokens of get procedure");
                return;
            else
                if Lines.To_String(Lines.Substring(S,T(2).Start,T(2).Start+T(2).Length-1))'Length> Max_URL_Length then
                    Put("the url length is invalid");
                    return;
                else
                    get(DB=>D,s=>Lines.To_String(Lines.Substring(S,T(2).Start,T(2).Start+T(2).Length-1)));
                end if;
            end if;
        elsif Lines.To_String(Lines.Substring(S,T(1).Start,T(1).Start+T(1).Length-1))="rem" then
            if NumTokens/=2 then
                Put("invalid number of tokens of rem procedure");
                return;
            else
                if Lines.To_String(Lines.Substring(S,T(2).Start,T(2).Start+T(2).Length-1))'Length> Max_URL_Length then
                    Put("the url length is invalid");
                    return;
                else
                    rem_password(DB=>D,s=>Lines.To_String(Lines.Substring(S,T(2).Start,T(2).Start+T(2).Length-1)));
                end if;
            end if;
        else
            Put("The function command does not exist in password manager");
            return;
        end if;
    end loop;
end Main;