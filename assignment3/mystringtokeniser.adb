package body MyStringTokeniser with SPARK_Mode is
   procedure Tokenise(S : in String; Tokens : in out TokenArray; Count : out Natural) is
      Index : Positive;
      Extent : TokenExtent;
      OutIndex : Integer := Tokens'First;
   begin
      Count := 0;
      if (S'First > S'Last) then
         return;
      end if;
      Index := S'First;
      while OutIndex <= Tokens'Last and Index <= S'Last and Count < Tokens'Length loop
         pragma Loop_Invariant
           (for all J in Tokens'First..OutIndex-1 =>
              (Tokens(J).Start >= S'First and
                   Tokens(J).Length > 0) and then
            Tokens(J).Length-1 <= S'Last - Tokens(J).Start);

         -- Task one part two:
         -- OutIndex represents the current number of token, which can be calculated by Tokens'First+Count
         --    Iter  |   Count |     OutIndex
         -- --------------------------------------
         --       0        0     Tokens'First + 0
         --       1        1     Tokens'First + 1
         --       2        2     Tokens'First + 2
         --      ...

         -- if we delete this loop invariant, there are three prove errors occur:
         -- 1. In mystringtokeniser.adb line 14, the overflow check might fail. For instance, OutIndex = Integer'First
         -- 2. In mystringtokeniser.adb line 50, array index check might fail. For instance, OutIndex = 0 and Tokens'First = 1
         -- 3. In mystringtokeniser.ads line 19, postcondition might fail(cannot prove Token(Index).Length>0). For instance, Index = 2147483646 and Tokens = (Positive'Last-1 => (Start => 1, Length => 0), others => (Start => Positive'Last-1, Length => 2))
         pragma Loop_Invariant (OutIndex = Tokens'First + Count);


         -- look for start of next token
         while (Index >= S'First and Index < S'Last) and then Is_Whitespace(S(Index)) loop
            Index := Index + 1;
         end loop;
         if (Index >= S'First and Index <= S'Last) and then not Is_Whitespace(S(Index)) then
            -- found a token
            Extent.Start := Index;
            Extent.Length := 0;

            -- look for end of this token
            -- positve'last -> infinity/ positive'First->1
            while Positive'Last - Extent.Length >= Index and then (Index+Extent.Length >= S'First and Index+Extent.Length <= S'Last) and then not Is_Whitespace(S(Index+Extent.Length)) loop
               Extent.Length := Extent.Length + 1;
            end loop;

            Tokens(OutIndex) := Extent;
            Count := Count + 1;

            -- check for last possible token, avoids overflow when incrementing OutIndex
            if (OutIndex = Tokens'Last) then
               return;
            else
               OutIndex := OutIndex + 1;
            end if;

            -- check for end of string, avoids overflow when incrementing Index
            if S'Last - Extent.Length < Index then
               return;
            else
               Index := Index + Extent.Length;
            end if;
         end if;
      end loop;
   end Tokenise;

end MyStringTokeniser;