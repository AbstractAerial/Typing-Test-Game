local UserInputService = game:GetService("UserInputService")

local TypeTester = {}
TypeTester.__index = TypeTester

function TypeTester.new(UI)
    local self = setmetatable({}, TypeTester)

    self.wordsPool = {"apple", "run", "banana", "happy", "cherry", "jump", "date", "blue", "elderberry", "swim", "fig", "bright", "grape", "dance", "honeydew", "sad", "kiwi", "laugh", "lemon", "green", "mango", "build", "nectarine", "quick", "orange", "sing", "papaya", "red", "quince", "write", "raspberry", "slow", "strawberry", "paint", "tangerine", "angry", "ugli", "climb", "vanilla", "brave","watermelon", "think", "xigua", "strong", "yam", "fly", "zucchini", "smart", "avocado", "read" }
	self.inSession = false

    self.timerAmount = 15
    self.wordsAmount = 30
    
    self._words = {}
    self._wrongKeys = {}

    self._currentWord = nil
    self._currentLetters = {}
    self._writtenLetters = {}
    self._coloredWords = {}

    self._currentWordIndex = 1
    self._currentLetterIndex = 0

    self._fullString = ""
    self._wordsLength = 0

    self.UI = UI
    --// <font color=""></font>
    return self
end


function TypeTester:SetTimer(n : number)
    self.timerAmount = n
end

function TypeTester:SetWordsAmount(n : number)
    self.wordsAmount = n
end

function TypeTester:SplitCurrentWord()
    self._currentLetters = {}

    for _, letter in self._currentWord:split("") do
        table.insert(self._currentLetters, letter)
    end
end

function TypeTester:GenerateWords()
    for index = 1, self.wordsAmount do
        local randomWord = self.wordsPool[math.random(#self.wordsPool)]
        table.insert(self._words, randomWord)

        if index == 1 then
            self._fullString = self._fullString..randomWord
            self._currentWord = randomWord
            self:SplitCurrentWord();
        else
            self._fullString = self._fullString.." "..randomWord
        end

        self._wordsLength += randomWord:len();
    end
end

function TypeTester:BeginTimer()
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
    self:BeginTimer();
end

function TypeTester:EndSession()
    self.inSession = false
end

function TypeTester:ApplyText(t : string)
    local textLabel = self.UI.Background.Container.TextArea
    textLabel.Text = t
end

function TypeTester._colorLetter(letter : string, color, joinWith : string?)
    return `{joinWith or ""}<font color="{color}">{letter}</font>`
end

function TypeTester:_PushCurrentWordAsColored()
    local word : string = ""

    for index, letter in ipairs(self._currentLetters) do
        if #self._writtenLetters < index then
            word = self._colorLetter(letter, "#797979", word)
            continue
        end

        if not table.find(self._wrongKeys, index) then
            word = self._colorLetter(letter, "#FFFFFF", word)
         else
            word = self._colorLetter(letter, "#FF0000", word)
         end
    end

    if #self._writtenLetters > #self._currentLetters then
        for i = #self._currentLetters + 1, #self._writtenLetters do
            local letter = self._writtenLetters[i]
            word = self._colorLetter(letter, "#FF0000", word) --// mark red
        end
    end

    self._coloredWords[self._currentWordIndex] = word --// sets the word as colored
    return word
end

function TypeTester:GetAllWordsColored()
    local words : string = ""
    self:_PushCurrentWordAsColored();

    for _, word in ipairs(self._coloredWords) do
        --// colored words will be in order.
        --// loop after this is everthing beyond what
        --// the word(s) the player has already written.
        words = words.." "..word
        print(words)
    end

    words = words.." "
    
    for i = self._currentWordIndex + 1, #self._words do
        local letter = self._words[i]
        words = self._colorLetter(letter.." ", "#797979", words)
    end

    return words
end

function TypeTester:Backspace()
    self._currentLetterIndex = (self._currentLetterIndex > 0) and self._currentLetterIndex-1 or 0

    if table.find(self._wrongKeys, #self._writtenLetters) then
        table.remove(self._wrongKeys, #self._writtenLetters)
    end

    table.remove(self._writtenLetters, #self._writtenLetters)
end

function TypeTester:Spacebar()
    self._currentLetterIndex = 0
    self._currentWordIndex += 1
    self._currentWord = self._words[self._currentWordIndex]

    self._writtenLetters = {}
    self._wrongKeys = {}
    self:SplitCurrentWord();
end

function TypeTester:Write(key : string)
    self._currentLetterIndex += 1
    table.insert(self._writtenLetters, key)

    if self._currentLetters[self._currentLetterIndex] ~= key then
        print("isn't key", self._currentLetters[self._currentLetterIndex], self._currentLetterIndex, key)
        table.insert(self._wrongKeys, self._currentLetterIndex);
    end
end

function TypeTester:ProcessKey(key : string)
    if key == "Backspace" then
        self:Backspace();
    elseif key == "Space" then
        self:Spacebar();
    else
        self:Write(key);
    end

    local text = self:GetAllWordsColored()
    self:ApplyText(text);
end

--TODO: Have to make it so you can go back to a previous word if the previous word wasn't completed.

function TypeTester:Init()
    self:GenerateWords()
    self:ApplyText(self._fullString);

    local function _onInput(input)
        local key = UserInputService:GetStringForKeyCode(input.KeyCode):lower();

        if not self.inSession then
            self:StartSession();
        end

        if input.KeyCode == Enum.KeyCode.Backspace then
            key = "Backspace"
        elseif input.KeyCode == Enum.KeyCode.Space then
            key = "Space"
        elseif key == " " then
            return
        end

        self:ProcessKey(key);
    end

    self.connection = UserInputService.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Keyboard then
            _onInput(input);
        end
	end)
end

function TypeTester:ShowResults()
    
end

function TypeTester:Destroy()
    
end

return TypeTester