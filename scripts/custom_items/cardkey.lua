local x = ScriptHost:CreateLuaItem()
x.Name = "Card Key"
x.ItemState = {}
x.ItemState['option'] = 'vanilla'
x.ItemState['qty'] = 0
x.ItemState['active'] = false
x.Icon = ImageReference:FromPackRelativePath('images/items/cardkey.png')
x.IconMods = "@disabled"

function x:CanProvideCodeFunc(code)
    return code == 'custom_cardkey'
end

function x:ProvidesCodeFunc(code)
    if self.ItemState['active'] then
        if self.ItemState['option'] == 'vanilla' then
            if code == 'cardkey' or code == 'keyitem' then
                return 1
            end
        elseif self.ItemState['option'] == 'progressive' then
            if code == 'cardkey_progressive' or code == 'keyitem' then
                return self.ItemState['qty']
            end
        end
    end
    return 0
end
function x:OnLeftClickFunc()
    if self.ItemState['option'] == 'progressive' and self.ItemState['qty'] < 10 then
        set_qty(self, self.ItemState['qty'] + 1)
    end

    if not self.ItemState['active'] then
        self.ItemState['active'] = true
        x.IconMods = ''
    end
end

function x:OnRightClickFunc()

    

    if self.ItemState['option'] == 'progressive' and self.ItemState['qty'] > 0 then
        set_qty(self, self.ItemState['qty'] -1 )
    end
    if self.ItemState['option'] == 'vanilla' and self.ItemState['active'] == true then
        self.ItemState['active'] = false
        x.Icon = ImageReference:FromImageReference(x.Icon, "@disabled")
    end
end

function x:OnMiddleClickFunc()
    if self.ItemState['option'] == 'split' then
        self.ItemState['option'] = 'vanilla'
        self.Icon = ImageReference:FromPackRelativePath('images/items/cardkey.png')
        self.Name = "Card Key"
        if not self.ItemState['active'] then
            self.IconMods = '@disabled'
        end
        print(self.ItemState['option'])
    elseif self.ItemState['option'] == 'vanilla' then
        self.ItemState['option'] = 'progressive'
        self.Icon = ImageReference:FromPackRelativePath('images/items/cardkeyprog.png')
        self.Name = "Progressive Card Key"
        set_qty(self, self.ItemState['qty'])
        
    else
        self.ItemState['option'] = 'split'
        self.Icon = ImageReference:FromPackRelativePath('images/items/cardkey.png')
        self.IconMods = '@disabled'
    end
    print(self.ItemState['option'])
end

function set_qty(self, qty)
    print("qty: " .. qty)
    self.ItemState['qty'] = qty
    if qty ~= 0 then
        print("here, setting icon mod:")
        self.ItemState['active'] = true
        self.IconMods = "overlay|images/overlays/" .. qty + 1 .. '.png'
        print(self.IconMods)
    end
    if qty == 0 then
        self.ItemState['active'] = false
        self:SetOverlay('')
        self.IconMods = "@disabled"
    end

end
