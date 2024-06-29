local UserInputService = game:GetService("UserInputService")

local TypeTester = {}
TypeTester.__index = TypeTester

function TypeTester.new(UI)
    local self = setmetatable({}, TypeTester)

	self.inSession = false
    self.timerAmount = 15
    self.wordsAmount = 30
    self.wordsPool = {"apple", "run", "banana", "happy", "cherry", "jump", "date", "blue", "elderberry", "swim", "fig", "bright", "grape", "dance", "honeydew", "sad", "kiwi", "laugh", "lemon", "green", "mango", "build", "nectarine", "quick", "orange", "sing", "papaya", "red", "quince", "write", "raspberry", "slow", "strawberry", "paint", "tangerine", "angry", "ugli", "climb", "vanilla", "brave","watermelon", "think", "xigua", "strong", "yam", "fly", "zucchini", "smart", "avocado", "read" }
    
    self.currentWords = {} 
    self.currentLetters = {}
    self.currentWordsLength = 0

    return self
end


function TypeTester:SetTimer(n : number)
    self.timerAmount = n
end

function TypeTester:SetWordsAmount(n : number)
    self.wordsAmount = 30
end

function TypeTester:GenerateWords()
    for i = 1, self.wordsAmount do
        local randomWord = self.wordsPool[math.random(#self.wordsPool)]
        
        table.insert(self.currentWords, randomWord)
        self.currentWordsLength += string.len(randomWord)

        for _, letter in randomWord:split("") do
            table.insert(self.currentLetters, letter)
        end
        table.insert(self.currentLetters, " ")
    end
end

function TypeTester:BeginCountdown()
    self.timer = task.spawn(function()
        for i = 1, self.timerAmount do
            task.wait(1)
        end
        self:EndSession();
        self.timer = nil;
    end)

end

function TypeTester:StartSession()
    self.inSession = true
end

function TypeTester:EndSession()
    self.inSession = false
end

function TypeTester:ApplyText(t : string)
    
end

function TypeTester:Init()
    UserInputService.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Keyboard then
			if not self.inSession then
                self:StartSession();
            else

			end
		end
	end)
end

function TypeTester:ShowResults()
    
end

function TypeTester:Destroy()
    
end

return TypeTester