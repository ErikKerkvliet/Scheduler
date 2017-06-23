require_relative "Scheduler_QualificationPanel"

class CreateListItem <  Wx::ListItem
    def initialize
        super
        super.set_background_colour(changingColor())
    end
end

class QualificationDialog < Wx::Dialog
    @nameTextCtrl = nil
    @qualificationDescription = nil
    @descriptionTextCtrl = nil

    def initialize(parent, listCtrl, title, dialogType)
        super( listCtrl, Wx::ID_ANY, title)
        @selected = parent.selected
        @listCtrl = listCtrl
        @qualificationDescription = parent.qualificationDescription
        @ids = parent.ids

        set_background_colour($BGCOLOR)

        fullSizer = Wx::VBoxSizer.new()
        fullPanel = Wx::Panel.new(self, -1)

        topSizer = Wx::VBoxSizer.new()
        topPanel = Wx::Panel.new(fullPanel, -1)

        qualificationSizer = Wx::HBoxSizer.new()
        qualificationPanel = Wx::Panel.new(topPanel, -1)

        nameText = Wx::StaticText.new(qualificationPanel, -1, "Qualification:")
        @nameTextCtrl = Wx::TextCtrl.new(qualificationPanel, -1, {size:Wx::Size.new(150, -1)})
        @nameTextCtrl.set_max_length(20)

        qualificationSizer.add(nameText, 0, Wx::ALL, 5)
        qualificationSizer.add(@nameTextCtrl, 0,Wx::LEFT|Wx::BOTTOM, 5)

        qualificationPanel.set_sizer(qualificationSizer)
        qualificationSizer.fit(topPanel)

        descriptionSizer = Wx::HBoxSizer.new()
        descriptionPanel = Wx::Panel.new(topPanel, -1)

        descriptionText = Wx::StaticText.new(descriptionPanel, -1, "Description:")
        @descriptionTextCtrl = Wx::TextCtrl.new(descriptionPanel, -1, "", {size:Wx::Size.new(150, 100), style:Wx::TE_MULTILINE|Wx::TE_NO_VSCROLL})
        @descriptionTextCtrl.set_max_length(200)

        descriptionSizer.add(descriptionText, 0, Wx::ALL, 5)
        descriptionSizer.add_spacer(6)
        descriptionSizer.add(@descriptionTextCtrl, 0, Wx::ALL, 5)

        descriptionPanel.set_sizer(descriptionSizer)

        descriptionSizer.fit(descriptionPanel)

        topSizer.add(qualificationPanel, 0, Wx::ALL, 5)
        topSizer.add(descriptionPanel, 0, Wx::ALL, 5)


        topPanel.set_sizer(topSizer)
        topSizer.fit(fullPanel)

        bottomSizer = Wx::HBoxSizer.new()
        bottomPanel = Wx::Panel.new(fullPanel, -1)

        okButton = Wx::Button.new(bottomPanel, -1, dialogType, {style:Wx::NO_BORDER})
        cancelButton = Wx::Button.new(bottomPanel, -1, "Cancel", {style:Wx::NO_BORDER})

        if dialogType == "Add"
            evt_button(okButton) { add() }
        end

        evt_button(cancelButton) { cancel() }

        bottomSizer.add(okButton, 0, Wx::LEFT, 35)
        bottomSizer.add_spacer(30)
        bottomSizer.add(cancelButton, 0, Wx::ALL, 0)
        bottomPanel.set_sizer(bottomSizer)
        bottomSizer.fit(fullPanel)

        fullSizer.add(topPanel, 0, Wx::ALL, 5)
        fullSizer.add(bottomPanel, 0, Wx::BOTTOM, 10)

        if dialogType == "Edit"
            evt_button(okButton) { edit() }
            selection = @listCtrl.get_selections()[0]
            if selection == nil
                return
            end
            @nameTextCtrl.set_value(@listCtrl.get_item(selection, 0).get_text())
            @descriptionTextCtrl.set_value(@qualificationDescription[selection])
        end

        fullPanel.set_sizer(fullSizer)
        fullSizer.fit(self)
    end

    def add()
        name = @nameTextCtrl.get_value()
        description = @descriptionTextCtrl.get_value()

        if name == ""
            message = Wx::MessageDialog.new(@listCtrl, "Name is needed", {style:Wx::ICON_ERROR})
            message.show_modal()
            return
        end

        query = "INSERT INTO qualifications (`id`, `qualification`, `description`) VALUES (NULL, '#{name}', '#{description}')"
        execQuery(query)


        index = @listCtrl.get_item_count()

        if index == 0
            @ids[0] = 1
        else
            @ids[@ids.length()] = @ids[index-1] + 1
        end
        @qualificationDescription[index] = description

        listItem = Wx::ListItem.new()

        listItem.set_id(index)
        listItem.set_text(name)

        @listCtrl.insert_item(listItem)

        $colorIndex = 1
        for i in 0..@listCtrl.get_item_count() - 1
            @listCtrl.set_item_background_colour(i, changingColor())
        end
        self.destroy()
    end

    def edit()
        name = @nameTextCtrl.get_value()
        description = @descriptionTextCtrl.get_value()

        if name == ""
            message = Wx::MessageDialog.new(@listCtrl, "Name is needed", {style:Wx::ICON_ERROR})
            message.show_modal()
            return
        end

        query = "UPDATE qualifications SET qualification = '#{name}', description = '#{description}' WHERE qualifications.Id = #{@ids[@selected]}"
        execQuery(query)

        @listCtrl.set_item(@selected, 0, name)
        @qualificationDescription[@selected] = description

        $colorIndex = 1
        for i in 0..@listCtrl.get_item_count() - 1
            @listCtrl.set_item_background_colour(i, changingColor())
        end

        self.destroy()
    end

    def cancel()
        self.destroy()
    end

end