local LocalizationService = game:GetService("LocalizationService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
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
    self._currentWord = nil

    self._rows = {}
    self._wordLabels = {}

    self._currentLetters = {}
    self._currentWrongKeys = {}

    self._previousWrongKeys = {}
    self._previousWrittenLetters = {}

    self._writtenLetters = {}

    self._currentWordIndex = 1
    self._currentLetterIndex = 0

    self._fullString = ""
    self._wordsLength = 0

    self.UI = UI
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

function TypeTester._checkIfFitInRow(word : TextLabel, row)
    local x = word.AbsolutePosition.X + word.AbsoluteSize.X + row.UIListLayout.Padding.Offset
    local y = row.AbsolutePosition.X + row.AbsoluteSize.X
    return (y - x) >= word.AbsoluteSize.X
end

function TypeTester:RecalculateRows()
    local label = self._wordLabels[self._currentWordIndex]
    local currentRow = self._rows[tonumber(label.Parent.Name)]
    local nextRow = self._rows[tonumber(label.Parent.Name)+1]

    local function _getLastWord(row)
        local children = row:GetChildren()
        return children[#children]
    end

    local function _deleteOtherRows()
        for index, row in self._rows do
            if row ~= currentRow and row.LayoutOrder > currentRow.LayoutOrder then
                row:Destroy();
                self._rows[index] = nil
            end
        end
    end

    local function _deleteOtherWordsOfRow()
        local remainingWords = (#currentRow:GetChildren()-1) - self._currentWordIndex

        for _, word in currentRow:GetChildren() do
            if word:IsA("TextLabel") and word.LayoutOrder > label.LayoutOrder then
                word:Destroy();
            end
        end
    end

    print(nextRow, currentRow)
    
    if not self._checkIfFitInRow(_getLastWord(currentRow), currentRow) 
    or nextRow and self._checkIfFitInRow(nextRow:GetChildren()[2], nextRow) then
        _deleteOtherRows()
        _deleteOtherWordsOfRow()
        self:DisplayWords(self._currentWordIndex+1, currentRow)
    end
end

function TypeTester:_createNewRow()
    local container = self.UI.Background.Container.TextHolder

    local row = ReplicatedStorage.UI_Elements.Row:Clone()
    row.LayoutOrder = #self._rows + 1
    row.Name = #self._rows + 1
    row.Parent = container

    table.insert(self._rows, row)
    return row
end

function TypeTester:_GetRowSizeInfo(row)
    local _rowListLayout = row.UIListLayout

    --// calculate the amount of offset created by the padding between words,
    --// and calculate the amount of space we have left in the row.
    local totalOffset = (#row:GetChildren()-1) * _rowListLayout.Padding.Offset
    local remainingRowSize = (row.AbsoluteSize - _rowListLayout.AbsoluteContentSize).X

    return totalOffset, remainingRowSize
end

function TypeTester:DisplayWords(startIndex : number?, row : Frame?)
    local elements = ReplicatedStorage.UI_Elements
    local container = self.UI.Background.Container.TextHolder
    local _currentRow = row or self:_createNewRow()

    for i = startIndex or 1, #self._words do
        local word = self._words[i]
            
        local _rowListLayout = _currentRow.UIListLayout
        local _rowAbsolute = _currentRow.AbsoluteSize
        local totalOffset, remainingRowSize = self:_GetRowSizeInfo(_currentRow)

        --// create new textlabel and set the parent to the current row,
        --// set text afterwards as AutomaticSize on the X axis might not set.
        local label = elements.TextLabel:Clone()
        label.LayoutOrder = i
        label.Name = word  
        label.Parent = _currentRow
        label.Text = word

        if not self._checkIfFitInRow(label, _currentRow) then
            --// if the new word goes outside of the bounds of the current row,
            --// start a new row.
            _currentRow = self:_createNewRow() 
            label.Parent = _currentRow
        end

        --// convert size of the label to scale as AutomaticSize is in pixels,
        --// Y axis is 1 to fill the full height of the row by default.
        local labelScaleSize = label.AbsoluteSize / _currentRow.AbsoluteSize
        label.Size = UDim2.fromScale(labelScaleSize.X, 1)

        --// store the textlabel in an array where we can easily retrieve it,
        --// and not have to first retrieve what row it is, as each index of the wordLabels corresponds to
        --// each word of self._words.
        self._wordLabels[i] = label;
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

function TypeTester:_GetCurrentWordAsColored()
    local word : string = ""

    for index, letter in ipairs(self._currentLetters) do
        if #self._writtenLetters < index then
            --// if amount written is less than the amount of letters the word has,
            --// color it gray, as the player has not yet gotten to that part of the word,
            --// and continue on to the next cycle to color the remaining ones gray.
            word = self._colorLetter(letter, "#797979", word)
            continue
        end

        if not table.find(self._currentWrongKeys, index) then
            --// if the current letter the loop is on has been located in
            --// the list of the invalid letters that the player has entered,
            --// it colors the letter red.
            word = self._colorLetter(letter, "#FFFFFF", word)
         else
            --// else, color it white as it's the correct letter.
            word = self._colorLetter(letter, "#FF0000", word)
         end
    end

    if #self._writtenLetters > #self._currentLetters then
        --// in the case where the player has written more letters than the word requires,
        --// the surplus letters will be considered as wrong and marked red.
        for i = #self._currentLetters + 1, #self._writtenLetters do
            local letter = self._writtenLetters[i]
            word = self._colorLetter(letter, "#FF0000", word) --// mark red
        end
     end

    return word
end

--TODO: make it so you can go back to words that you haven't fully completed but skipped.

function TypeTester:Backspace()
    local _previousIndex = tostring(tostring(self._currentWordIndex-1))
    local _previousWordMistakes = self._previousWrongKeys[_previousIndex]

    --// if you're on the first letter of the word and press backspace
    --// and you've made a mistake on the previous word
    if self._currentLetterIndex == 0 and _previousWordMistakes then

        --// go back to the previous word, starting at the latest letter.
        self._currentWordIndex -= 1
        self._currentWord = self._words[self._currentWordIndex]

        local _previousWrittenLetters = self._previousWrittenLetters[_previousIndex]
        self._writtenLetters = _previousWrittenLetters

        self:SplitCurrentWord();
        self._currentLetterIndex = #self._writtenLetters
        self._currentWrongKeys = _previousWordMistakes
    end

    local _isMistakeLetter = table.find(
        self._currentWrongKeys,
        self._currentLetterIndex
    )

    if _isMistakeLetter then
        --// if the deleted was a wrong letter/mistake,
        --// we delete it from the table which holds the wrong keys
        --// since they've deleted it, ultimately fixing it.
        table.remove(self._currentWrongKeys, _isMistakeLetter)
    end

    --// remove the current letter from the written letters because it's now deleted,
    --// and go back a letter from where it is now.
    table.remove(self._writtenLetters, #self._writtenLetters)
    self._currentLetterIndex = (self._currentLetterIndex > 0) and self._currentLetterIndex-1 or 0
end

function TypeTester:Spacebar()
    if #self._writtenLetters == 0 then
        --// the player must write at least 1 letter of the word
        --// before going to the next word.
        return
    end

    --// once the player decides to move on to the next word,
    --// if the current word has a mistake in it, we save the mistake
    --// into a list containing the mistakes made in their respective words.
    local _currentWordIndex = tostring(self._currentWordIndex)
    if #self._currentWrongKeys > 0 then
        self._previousWrongKeys[_currentWordIndex] = self._currentWrongKeys
    else
        self._previousWrongKeys[_currentWordIndex] = nil;
    end

    --// saves all of the letters written in the current word (right ones AND wrong ones)
    --// in a table that contains what the player wrote in each word, to be able to see
    --// where they made mistakes and which ones they've finished in a easy way.
    self._previousWrittenLetters[_currentWordIndex] = self._writtenLetters --// (doesnt need to be string?)
    
    --// moving to the next letter and resetting variables
    self._currentWordIndex += 1
    self._currentLetterIndex = 0
    self._currentWord = self._words[self._currentWordIndex]
    

    self._writtenLetters = {}
    self._currentWrongKeys = {}
    self:SplitCurrentWord();
end

function TypeTester:Write(key : string)
    self._currentLetterIndex += 1
    table.insert(self._writtenLetters, key)

    if self._currentLetters[self._currentLetterIndex] ~= key then
        table.insert(self._currentWrongKeys, self._currentLetterIndex);
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

    local currentLabel = self._wordLabels[self._currentWordIndex]
    currentLabel.Text = self:_GetCurrentWordAsColored() 
    
    self:RecalculateRows();
end

--TODO: be able to go back on a word that you haven't finished yet, cus when you press

function TypeTester:Init()
    self:GenerateWords()
    self:DisplayWords();

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