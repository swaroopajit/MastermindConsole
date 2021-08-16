require 'colorize'
require 'colorized_string'
class MasterMind

    def initialize()
    end

    def selectGameMode(game_mode)
        @game_mode = game_mode
    end

    def gameStart()
        if @game_mode == 1
            #user is the code-maker
            puts "Enter your code"
            validEntry = false
            while validEntry == false
                @code = gets.chomp
                validEntry = checkValidEntry(@code)
            end
            @code = @code.split("")
            @s = [] #possible codes
            for i in 1..6 do
                for j in 1..6 do
                    for k in 1..6 do
                        for l in 1..6 do
                            @s.push((i.to_s)+(j.to_s)+(k.to_s)+(l.to_s))
                        end
                    end
                end
            end
            guess = ""
            clue = []
            for i in 0..11 do

                puts "Computer's Turn ##{i+1}:"

                sleep 1
                
                #code the guess 
                if i == 0
                    guess = "1122"
                else
                    guess = getNextGuess(clue,guess)
                end

                clue = []
                # 0 - nothing about this digit is right
                # 1 - the number exists but the position is wrong
                # 2 - the number and the position are both correct

                clue = gameIteration(guess)
                if(solved(clue) == true)
                    break
                end
                puts ""
            end

            if (solved(clue) == false)    
                puts ""
                puts "Good job! The computer was not able to guess your code!"
            else
                puts ""
                puts "Game Over! The computer cracked the code!"
            end
            puts ""

        elsif @game_mode == 2
            #user is the code-breaker
            @code = []

            #make a random code
            for i in 0..3
                @code.push((1+rand(5)).to_s)
            end

            for i in 0..11 do
                puts "Turn ##{i+1}: Type in 4 numbers from 1-6 to guess the code"
                if i == 11
                    puts "This is your last turn".colorize(:red)
                end
                validEntry = false
                while validEntry == false
                    entry = gets.chomp
                    validEntry = checkValidEntry(entry)
                end
                clue = []
                # 0 - nothing about this digit is right
                # 1 - the number exists but the position is wrong
                # 2 - the number and the position are both correct
                clue = gameIteration(entry)
                if(solved(clue) == true)
                    break
                end
                puts ""
            end
            if solved(clue) == false
                print "Game over! Here's the code you were trying to break: "
                puts ""
                for j in 0..3 do
                    printNumber(@code[j])
                end
            else
                puts ""
                puts "Good job! You've cracked the code!"
            end
            puts ""
        end     
    end

    def checkValidEntry(etr)
        if etr.length != 4
            if etr.length > 4
                puts "Uh-oh! You can only enter upto 4 digits.Please try again!"
            else
                puts "Uh-oh! You have to enter 4 digits.Please try again!"
            end
            return false
        else
            etr = etr.split("")
            for i in 0..etr.length-1 do
                if !(etr[i].match?(/[[:digit:]]/))
                    puts "You can only enter digits!"
                    return false
                end
            end
            return true
        end
    end

    def getNextGuess(clue,guess)
        blackPins = 0
        whitePins = 0

        for i in 0..clue.length-1 do
            if clue[i] == "2" 
                blackPins += 1
            elsif clue[i] == "1"
                whitePins += 1
            end
        end

        #puts ("blackPins: #{blackPins}")
        #puts ("whitePins: #{whitePins}")

        is_used = [nil,nil,nil,nil]
        for i in 0..@s.length do
            if @s[i] != nil
                guessTemp = guess.clone.split("")
                currentTemp = @s[i].clone.split("")



                blackPinsNext = 0
                whitePinsNext = 0
                for j in 0..3 do
                    if currentTemp[j] == guessTemp[j] and currentTemp[j] != nil
                        blackPinsNext += 1
                        currentTemp[j] = nil
                        guessTemp[j] = nil
                    end 
                end
                for j in 0..3 do
                    for k in 0..3 do
                        if currentTemp[j] == guessTemp[k] and currentTemp[j] != nil
                            whitePinsNext += 1
                            currentTemp[j] = nil
                            guessTemp[k] = nil
                        end 
                    end
                end

                #puts ("currentguess: #{@s[i]}")
                #puts ("blackPinsNext: #{blackPinsNext}")
                #puts ("whitePinsNext: #{whitePinsNext}")

                if (blackPinsNext != blackPins) or (whitePinsNext != whitePins)
                    #puts("removed!")
                    @s[i] = nil
                end
            end
        end

        @s = removeNil(@s)
        @s.sort
        return @s[0]
    end

    def removeNil(arr)
        retArr = []
        for i in 0..arr.length-1
            if(arr[i]!= nil)
                retArr.push(arr[i])
            end
        end
        return retArr
    end

    def gameIteration(entry)
        clue = []
        entry = entry.split("")
        clue.clear
        codeTemp = []
        codeTemp = @code.clone
        for i in 0..3 do
            printNumber(entry[i])
            clueValue = 0
            
            #cycle through code to check matching pos and number
            if entry[i] == codeTemp[i]
                clueValue = 2
                codeTemp[i] = nil
                entry[i] = nil
            end

            if clueValue != 0
                clue.push(clueValue.to_s)
            end
        end

        for i in 0..3 do
            clueValue = 0
            for j in 0..3 do
                if entry[i] != nil and entry[i] == codeTemp[j]
                    codeTemp[j] = nil
                    entry[i] = nil
                    clueValue = 1
                end
            end
            if clueValue != 0
                clue.push(clueValue.to_s)
            end
        end

        clue = clue.sort

        if (solved(clue) == false)    
            for j in 0..clue.length do
                printClue(clue[clue.length - j])
            end
        end
        
        puts ""
        return clue
    end

    def solved(clue)
        #check if the user has solved the code
        counter =0
        for i in 0..clue.length-1 do
            if clue[i] == "2"
                counter +=1
            end
        end
        if counter == 4
            return true
        else
            return false
        end
    end

    def printClue(num)
        #print the clues
        print ("  ")
        if num == "1"
            #right number, wrong position
            pin = "\u25EF"
            print " "
            print ColorizedString[pin].colorize(:color => :red)
            print " "
        elsif num == "2"
            #right number, right position
            pin = "\u2B24"
            print " "
            print ColorizedString[pin].colorize(:color => :red)
            print " "
        end
    end

    def printNumber(num)
        #print the number with it's matching colour
        print(" ")
        if num == "1"
            print ColorizedString["  1  "].colorize(:color => :light_white, :background => :red)
        elsif num == "2"
            print ColorizedString["  2  "].colorize(:color => :light_white, :background => :blue)
        elsif num == "3"
            print ColorizedString["  3  "].colorize(:color => :light_white, :background => :green)
        elsif num == "4"
            print ColorizedString["  4  "].colorize(:color => :light_white, :background => :magenta)
        elsif num == "5"
            print ColorizedString["  5  "].colorize(:color => :light_white, :background => :yellow)
        elsif num == "6"
            print ColorizedString["  6  "].colorize(:color => :light_white, :background => :cyan)
        end
        print(" ")
    end
end

game = MasterMind.new()

puts ""
puts "It's time to play Mastermind!"
puts ""
puts "In this version of the game you will playing against the computer. You can be either:"
puts "1. Code Maker"
puts "2. Code Breaker"
puts ""

puts "Here are the different colours/numbers you will have to choose from"
for i in 1..6 do
    game.printNumber(i.to_s)
end

puts ""
puts ""

puts "The code maker will get to choose 4 out of the 6 colours/numbers to create a code."
puts "For the code breaker to win, they have to crack the code within 12 turns, with the help of the clues given at each turn."
puts "Note: Repition of colours/numbers is allowed."
puts ""
puts ""

puts "Clues legend:"

pin = "\u2B24"
print " "
print ColorizedString[pin].colorize(:color => :red)
print " \t:\t"
puts "This means that you have found 1 right number/colour in the right location"
pin = "\u25EF"
print " "
print ColorizedString[pin].colorize(:color => :red)
print " \t:\t"
puts "This means that you have found 1 right number/colour, but in the wrong location"

puts ""

puts("Would you like to play as the code maker or code breaker?")
puts("Enter 1 to be the code maker")
puts("Enter 2 to be the code breaker")
game_selection = 0
game_selected = false
while game_selected == false
    game_selection = gets.chomp.to_i
    if game_selection !=1 and game_selection!= 2
        puts "Please enter a valid option!"
    else
        game_selected = true
    end
end
game.selectGameMode(game_selection)
game.gameStart