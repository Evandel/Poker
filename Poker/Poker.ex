defmodule Poker do
    def deal(list \\ shuffle()) do #main / everything has to be sorted to work properly
        deck = list
        {hand1, hand2} = createHand(deck)
        hand1 = Enum.sort(hand1)
        hand2 = Enum.sort(hand2)
        winner = determineWinner(hand1,hand2)
        printHand(winner)
    end

    def printHand([],ret), do: ret #Prints hand like normal cards
    def printHand(hand, ret \\ []) do
        if length(hand) > 0 do
            suit = cond do
                hd(hand) <= 13 -> 0 #clubs
                hd(hand) <= 26 -> 1 #diamond
                hd(hand) <= 39 -> 2 #heart
                hd(hand) <= 52 -> 3 #spade
                true -> nil             
            end
            rank = rem(hd(hand),13)
            if rank == 0 do
                rank = 13
                add = cond do
                    suit == 0 -> Integer.to_string(rank) <> "C"
                    suit == 1 -> Integer.to_string(rank) <> "D"
                    suit == 2 -> Integer.to_string(rank) <> "H"
                    suit == 3 -> Integer.to_string(rank) <> "S"
                end
                ret = ret ++ [add]
                printHand(tl(hand), ret)
            else
                add = cond do
                    suit == 0 -> Integer.to_string(rank) <> "C"
                    suit == 1 -> Integer.to_string(rank) <> "D"
                    suit == 2 -> Integer.to_string(rank) <> "H"
                    suit == 3 -> Integer.to_string(rank) <> "S"
                end
                ret = ret ++ [add]
                printHand(tl(hand), ret)
            end
        end
                    
    end

    def shuffle() do #Draws 10 random cards /EXTRA FUNCTION (NOT NEEDED)
        1..10 |> Enum.map(fn _ -> :rand.uniform(52) end)
    end

    def createHand(list, hand1 \\ [], hand2 \\ []) #base case
    def createHand([], hand1, hand2), do: {hand1, hand2} #empty list
    def createHand(list, hand1, hand2) do #creates both hands alternating order
        hand1 = hand1 ++ [hd(list)]
        list = tl(list)
        hand2 = hand2 ++ [hd(list)]
        createHand(tl(list), hand1, hand2)
    end

    def determineHand(hand) do #has to be sorted 
        sortedHand = Enum.sort(hand)
        determine = cond do
            determineRoyalFlush(sortedHand) == 1 -> 1
            determineStraightFlush(sortedHand) == 1 -> 2
            determineFour(sortedHand) == 1 -> 3
            determineFullHouse(sortedHand) == 1 -> 4
            determineFlush(sortedHand) == 1 -> 5
            determineStraight(sortedHand) == 1 -> 6
            determineTwoPairs(sortedHand) == 1 -> 8
            determineTriple2(sortedHand) == 1 -> 7
            determinePair(sortedHand) == 1 -> 9
            true -> 10
        end
    end

    def determineWinner(hand1,hand2) do
        whatHand1 = determineHand(hand1)
        whatHand2 = determineHand(hand2)
        cond do
            whatHand1 < whatHand2 -> hand1
            whatHand1 > whatHand2 -> hand2
            whatHand1 == whatHand2 -> tieBreak(hand1,hand2)
        end
    end

    def tieBreak(hand1, hand2) do
        whatHand = determineHand(hand1)
        retHand = cond do
            whatHand == 1 -> tieBreak1(hand1,hand2)
            whatHand == 2 -> tieBreak26(hand1,hand2)
            whatHand == 3 -> tieBreak3(hand1,hand2)
            whatHand == 4 -> tieBreak48(hand1,hand2)
            whatHand == 5 -> tieBreak5(hand1,hand2)
            whatHand == 6 -> tieBreak26(hand1,hand2)
            whatHand == 8 -> tieBreak7(hand1,hand2)
            whatHand == 7 -> tieBreak48(hand1,hand2)
            whatHand == 9 -> tieBreak9(hand1,hand2)
            whatHand == 10 -> tieBreak5(hand1,hand2)
        end    
    end

    def tieBreak1(hand1,hand2) do
        high1 = Enum.max(hand1)
        high2 = Enum.max(hand2)
        if high1 > high2 do
            hand1
        else
            hand2
        end
    end

    def tieBreak26(hand1,hand2) do
        new1 = Enum.map(hand1, fn x -> rem(x,13) end)
        new2 = Enum.map(hand2, fn x -> rem(x,13) end)
        high1 = Enum.max(new1)
        high2 = Enum.max(new2)
        ret = cond do
            high1 == high2 -> tieBreak1(hand1,hand2)
            true -> tieBreak26Helper(hand1,hand2)
        end
    end

    def tieBreak26Helper(hand1,hand2) do
        new1 = Enum.map(hand1, fn x -> rem(x,13) end)
        new2 = Enum.map(hand2, fn x -> rem(x,13) end)
        high1 = Enum.max(new1)
        high2 = Enum.max(new2)
        if high1 > high2 do
            hand1
        else
            hand2
        end
    end

    def tieBreak3(hand1,hand2) do
        high1 = highestFour(hand1)
        high2 = highestFour(hand2)
        high1 = cond do 
            high1 == 0 -> 13
            high1 == 1 -> 14
            true -> high1
        end
        high2 = cond do
            high2 == 0 -> 13
            high2 == 1 -> 14
            true -> high2
        end
        if high1 > high2 do
            high1
        else
            high2
        end
    end

    def tieBreak48(hand1,hand2) do
        high1 = tieBreak48Helper(hand1)
        high2 = tieBreak48Helper(hand2)
        high1 = cond do 
            high1 == 0 -> 13
            high2 == 1 -> 14
            true -> high1
        end
        high2 = cond do
            high2 == 0 -> 13
            high2 == 1 -> 14
            true -> high2
        end
        if high1 > high2 do
            high1
        else
            high2
        end        
    end

    def tieBreak48Helper(hand, counted \\ [], count \\ 0, lock \\ 0, count2 \\ 0, count3 \\ 0) do
        if length(hand) > 0 do
            if Enum.member?(counted, rem(hd(hand),13)) do
                lock = cond do
                    rem(hd(hand),13) == Enum.at(counted,0) -> 1
                    rem(hd(hand),13) == Enum.at(counted,1) -> 2
                    rem(hd(hand),13) == Enum.at(counted,2) -> 3
                    true -> 4
                end
                if lock == 1 do
                    count = count + 1
                    if count == 2 do
                        Enum.at(counted,0)
                    else
                        tieBreak48Helper(tl(hand), counted, count, lock, count2, count3)
                    end
                else
                    if lock == 2 do
                        count2 = count2 + 1
                        if count2 == 2 do
                            Enum.at(counted,1)
                        else
                            tieBreak48Helper(tl(hand), counted, count, lock, count2,count3)                                     
                        end
                    else
                        count3 = count3 + 1
                        if count3 == 2 do
                            Enum.at(counted,2)
                        else
                            tieBreak48Helper(tl(hand), counted, count, lock, count2,count3)                                     
                        end                    
                    end
                end
            else
                counted = counted ++ [rem(hd(hand),13)]
                tieBreak48Helper(tl(hand), counted, count, lock, count2,count3) 
            end
        end
    end

    def tieBreak5(hand1,hand2) do
        new1 = tieBreak5Helper(hand1)
        new2 = tieBreak5Helper(hand2)
        cond do
            Enum.at(new1,0) > Enum.at(new2,0) -> hand1
            Enum.at(new1,0) < Enum.at(new2,0) -> hand2
            true -> cond do
                Enum.at(new1,1) > Enum.at(new2,1) -> hand1
                Enum.at(new1,1) < Enum.at(new2,1) -> hand2
                true -> cond do
                    Enum.at(new1,2) > Enum.at(new2,2) -> hand1
                    Enum.at(new1,2) < Enum.at(new2,2) -> hand2
                    true -> cond do
                        Enum.at(new1,3) > Enum.at(new2,3) -> hand1
                        Enum.at(new1,3) < Enum.at(new2,3) -> hand2
                        true -> cond do
                            Enum.at(new1,4) > Enum.at(new2,4) -> hand1
                            Enum.at(new1,4) < Enum.at(new2,4) -> hand2
                            true -> tieBreak26Helper(hand1,hand2)
                        end
                    end
                end
            end
        end
    end

    def tieBreak5Helper(hand1) do #converts list to just ranks
        new1 = Enum.map(hand1, fn x -> rem(x,13) end)
        new1 = Enum.reverse(new1)
        last = Enum.at(new1,length(new1)-1)
        if last == 1 do
            new1 = new1 -- [last]
            new1 = [last | new1]
            head = cond do 
                hd(new1) == 1 -> 14
                true -> hd(hand1)
            end
            new1 = [head | tl(new1)]
            head2 = cond do
                hd(tl(new1)) == 0 -> 13
                true -> hd(tl(new1))
            end
            new1 = new1 -- [0]
            new1 = new1 -- [head2]
            new1 = [head | [head2 | tl(new1)]]
            new1 = Enum.sort(new1)
            new1 = Enum.reverse(new1)
        else
            head = cond do 
                hd(new1) == 0 -> 13
                hd(new1) == 1 -> 14
                true -> hd(hand1)
            end
            new1 = [head | new1]
            new1 = new1 -- [head]
            new1 = Enum.sort(new1)
            new1 = Enum.reverse(new1)
        end
    end

    def highestFour([]), do: 0
    def highestFour(hand, counted \\ []) do
        new1 = Enum.map(hand, fn x -> rem(x,13) end)
        head = hd(new1)
        last = Enum.at(new1,length(new1)-1)
        ret = cond do
            hd(new1) == last -> last
            hd(new1) == hd(tl(new1)) -> hd(new1)
            true -> last
        end
    end

    def tieBreak7(hand1,hand2) do
        new1 = tieBreak7Helper2(tieBreak7Helper(hand1))
        new2 = tieBreak7Helper2(tieBreak7Helper(hand2))
        cond do
            Enum.max(new1) > Enum.max(new2) -> hand1
            Enum.max(new1) < Enum.max(new2) -> hand2
            true -> cond do
                Enum.min(new1) > Enum.min(new2) -> hand1
                Enum.min(new1) < Enum.min(new2) -> hand2
                true -> tieBreak7Helper3(hand1,hand2)
            end
        end
    end

    def tieBreak7Helper3(hand1, hand2) do
        new1 = tieBreak7Helper(hand1)
        temp1 = Enum.map(hand1, fn x -> rem(x,13) end)
        temp1 = Enum.uniq(temp1)
        final1 = temp1 -- new1

        new2 = tieBreak7Helper(hand2)
        temp2 = Enum.map(hand2, fn x -> rem(x,13) end)
        temp2 = Enum.uniq(temp2)
        final2 = temp2 -- new2    

        cond do
            hd(final1) > hd(final2) -> hand1
            hd(final1) < hd(final2) -> hand2
            true -> tieBreak7Helper4(hand1,hand2,final1,final2)
        end  
    end

    def tieBreak7Helper4(hand1,hand2, final1, final2) do
        suit1 = cond do 
            rem(Enum.at(hand1,0),13) == hd(final1) -> Enum.at(hand1,0)
            rem(Enum.at(hand1,1),13) == hd(final1) -> Enum.at(hand1,1)
            rem(Enum.at(hand1,2),13) == hd(final1) -> Enum.at(hand1,2)
            rem(Enum.at(hand1,3),13) == hd(final1) -> Enum.at(hand1,3)
            rem(Enum.at(hand1,4),13) == hd(final1) -> Enum.at(hand1,4)
            true -> 0
        end
        suit2 = cond do
            rem(Enum.at(hand2,0),13) == hd(final2) -> Enum.at(hand2,0)
            rem(Enum.at(hand2,1),13) == hd(final2) -> Enum.at(hand2,1)
            rem(Enum.at(hand2,2),13) == hd(final2) -> Enum.at(hand2,2)
            rem(Enum.at(hand2,3),13) == hd(final2) -> Enum.at(hand2,3)
            rem(Enum.at(hand2,4),13) == hd(final2) -> Enum.at(hand2,4)
            true -> 0
        end
        if suit1 > suit2 do
            hand1
        else
            hand2
        end
    end

    def tieBreak7Helper2(hand) do
        head = cond do
            hd(hand) == 1 -> 14
            hd(hand) == 0 -> 13
            true -> hd(hand)
        end
        tail = cond do
            hd(tl(hand)) == 1 -> 14
            hd(tl(hand)) == 0 -> 13
            true -> tl(hand)
        end
        ret = [head | tail]
    end

    def tieBreak7Helper(hand,counted \\ [],found \\ 0, blacklist \\ -1, ret \\ []) do 
        if length(hand) > 0 do
            if Enum.member?(counted, rem(hd(hand),13)) do  
                if rem(hd(hand),13) != blacklist do
                    found = found + 1
                    if found != 2 do
                        blacklist = rem(hd(hand),13)
                        ret = ret ++ [blacklist]
                        tieBreak7Helper(tl(hand), counted, found, blacklist, ret)
                    else
                        ret = ret ++ [rem(hd(hand),13)]
                    end
                else
                    tieBreak7Helper(tl(hand), counted, found, blacklist, ret)
                end
            else
                counted = counted ++ [rem(hd(hand),13)]
                tieBreak7Helper(tl(hand), counted, found, blacklist, ret)
            end
        end
    end

    def tieBreak9(hand1,hand2) do
        pair1 = tieBreak9Helper(hand1)
        pair2 = tieBreak9Helper(hand2)
        cond do
            pair1 > pair2 -> hand1
            pair1 < pair2 -> hand2
            true -> tieBreak9Helper2(hand1,hand2)
        end
    end

    def tieBreak9Helper2(hand1,hand2) do
        new1 = tieBreak9Helper(hand1)
        temp1 = Enum.map(hand1, fn x -> rem(x,13) end)
        temp1 = Enum.uniq(temp1)
        final1 = temp1 -- [new1]

        new2 = tieBreak9Helper(hand2)
        temp2 = Enum.map(hand2, fn x -> rem(x,13) end)
        temp2 = Enum.uniq(temp2)
        final2 = temp2 -- [new2]    

        cond do
            hd(final1) > hd(final2) -> hand1
            hd(final1) < hd(final2) -> hand2
            true -> tieBreak7Helper4(hand1,hand2,final1,final2)
        end 
    end

    def tieBreak9Helper(hand1,counted \\ []) do
        if length(hand1) > 0 do
            if Enum.member?(counted, rem(hd(hand1),13)) do
                cond do
                    rem(hd(hand1),13) == 0 -> 13
                    rem(hd(hand1),13) == 1-> 14
                    true -> rem(hd(hand1),13)
                end
            else
                counted = counted ++ [rem(hd(hand1),13)]
                tieBreak9Helper(tl(hand1), counted)
            end
        end        
    end

    def determineStraight([]), do: 0
    def determineStraight(hand, check \\ 0, x \\ 0, x2 \\ 0) do #only works if sorted
        if length(hand) > 1 do
            x = rem(hd(hand),13)
            x2 = rem(hd(tl(hand)),13)
            if ((x+1) == x2  || rem(x+1,13) == x2) && ((x+1) != 1) do
                check = 1
                determineStraight(tl(hand), check, x, x2)
            else
                if x == 1 do
                    if x2 == 10 do
                        check = 1
                        determineStraight(tl(hand), check, x, x2)
                    else
                        check = 0
                    end
                else
                    check = 0
                end
            end
        else
            check = 1
        end     
    end

    def determineFlush([]), do: 0
    def determineFlush(hand, check \\ 0) do #only works if sorted
        if length(hand) > 1 do
            inCheck = cond do #first
                hd(hand) <= 13 -> 0 #clubs
                hd(hand) <= 26 -> 1 #diamond
                hd(hand) <= 39 -> 2 #heart
                hd(hand) <= 52 -> 3 #spade
                true -> nil
            end
            inCheck2 = cond do #second
                hd(tl(hand)) <= 13 -> 0 #clubs
                hd(tl(hand)) <= 26 -> 1 #diamond
                hd(tl(hand)) <= 39 -> 2 #heart
                hd(tl(hand)) <= 52 -> 3 #spade
                true -> nil
            end
            if inCheck == inCheck2 do
                check = 1
                determineFlush(tl(hand), check)
            else
                check = 0
            end
        else
            check = 1
        end
    end

    def determineStraightFlush([]), do: 0
    def determineStraightFlush(hand) do #uses straight and flush
        straight = determineStraight(hand)
        flush = determineFlush(hand)
        if straight == 1 && flush == 1 do
            1
        else
            0
        end
    end

    def determineRoyalFlush([]), do: 0
    def determineRoyalFlush(hand) do 
        hand2 = tl(hand) ++ [hd(hand)]
        check = cond do
            hand2 == [10,11,12,13,1] -> 1
            hand2 == [23,24,25,26,14] -> 1
            hand2 == [36,37,38,39,27] -> 1
            hand2 == [49,50,51,52,40] -> 1
            true -> 0
        end
    end

    def determineHighCard([],highest), do: highest #DOES THE SAME THING AS ENUM.MAX
    def determineHighCard(hand, highest \\ 0) do
        if length(hand) > 0 do
            if hd(hand) > highest do
                determineHighCard(tl(hand),hd(hand))
            else
                determineHighCard(tl(hand), highest)
            end
        end
    end

    def determinePair([]), do: 0
    def determinePair(hand, counted \\ []) do
        if length(hand) > 0 do
            if Enum.member?(counted, rem(hd(hand),13)) do
                1
            else
                counted = counted ++ [rem(hd(hand),13)]
                determinePair(tl(hand), counted)
            end
        else
            0
        end
    end

    def determineTwoPairs([]), do: 0 #Detects full house as 2 pairs
    def determineTwoPairs(hand,counted \\ [],found \\ 0, blacklist \\ -1) do 
        if length(hand) > 0 do
            if Enum.member?(counted, rem(hd(hand),13)) do  
                if rem(hd(hand),13) != blacklist do
                    found = found + 1
                    if found != 2 do
                        blacklist = rem(hd(hand),13)
                        determineTwoPairs(tl(hand), counted, found, blacklist)
                    else
                        1
                    end
                else
                    determineTwoPairs(tl(hand), counted, found, blacklist)
                end
            else
                counted = counted ++ [rem(hd(hand),13)]
                determineTwoPairs(tl(hand), counted, found, blacklist)
            end
        else
            0
        end
    end

    def determineTriple([]), do: 0
    def determineTriple(hand, counted \\ [], found \\ 0, lock \\ 0) do #uses two pairs
        if determineTwoPairs(hand) == 1 || determineFour(hand) == 1 do 
            0
        else
            if length(hand) > 0 do
                if Enum.member?(counted, rem(hd(hand),13)) do  
                    if lock == 0 do
                        found = rem(hd(hand),13)
                        lock = 1
                        determineTriple(tl(hand), counted, found, lock)
                    else
                        1
                    end
                else
                    counted = counted ++ [rem(hd(hand),13)]
                    determineTriple(tl(hand), counted, found, lock)
                end
            else
                0
            end
        end
    end

    def determineFour([]), do: 0
    def determineFour(hand, counted \\ [], found \\ 0, lock \\ 0) do #uses two pairs
        if determineTwoPairs(hand) == 1 do 
            0
        else
            if length(hand) > 0 do
                if Enum.member?(counted, rem(hd(hand),13)) do  
                    if lock != 2 do
                        found = rem(hd(hand),13)
                        lock = lock + 1
                        determineFour(tl(hand), counted, found, lock)
                    else
                        1
                    end
                else
                    counted = counted ++ [rem(hd(hand),13)]
                    determineFour(tl(hand), counted, found, lock)
                end
            else
                0
            end
        end
    end

    def determineTriple2([]), do: 0
    def determineTriple2(hand, counted \\ [], count \\ 0, lock \\ 0, count2 \\ 0, count3 \\ 0) do
        if length(hand) > 0 do
            if Enum.member?(counted, rem(hd(hand),13)) do
                lock = cond do
                    rem(hd(hand),13) == Enum.at(counted,0) -> 1
                    rem(hd(hand),13) == Enum.at(counted,1) -> 2
                    rem(hd(hand),13) == Enum.at(counted,2) -> 3
                    true -> 4
                end
                if lock == 1 do
                    count = count + 1
                    if count == 2 do
                        1
                    else
                        determineTriple2(tl(hand), counted, count, lock, count2, count3)
                    end
                end
                if lock == 2 do
                    count2 = count2 + 1
                    if count2 == 2 do
                        1
                    else
                        determineTriple2(tl(hand), counted, count, lock, count2,count3)                                     
                    end
                else
                    count3 = count3 + 1
                    if count3 == 2 do
                        1
                    else
                        determineTriple2(tl(hand), counted, count, lock, count2,count3)                                     
                    end                    
                end
            else
                counted = counted ++ [rem(hd(hand),13)]
                determineTriple2(tl(hand), counted, count, lock, count2,count3) 
            end
        else
            0
        end
    end

    def determineFullHouse([]), do: 0
    def determineFullHouse(hand) do
        new = tieBreak48Helper(hand)
        temp = Enum.map(hand, fn x -> rem(x,13) end)
        temp = Enum.uniq(temp)
        temp = temp -- [new]
        if length(temp) == 1 do
            1
        else
            0
        end
    end
end