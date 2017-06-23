
class TimeSlotDialog < Wx::Dialog
    def initialize(parent, listCtrl, title, dialogType)
        super(parent, Wx::ID_ANY, title)
        @selected = parent.selected
        @listCtrl = listCtrl
        @timeSlotDescription = parent.timeSlotDescription
        @ids = parent.ids

        set_background_colour($BGCOLOR)

        fullPanel = Wx::Panel.new(self, -1)
        fullSizer = Wx::VBoxSizer.new()

        topPanel = Wx::Panel.new(fullPanel, -1)
        topSizer = Wx::HBoxSizer.new()

        leftSizer = Wx::VBoxSizer.new()
        leftPanel = Wx::Panel.new(topPanel, -1)

        nameSizer = Wx::HBoxSizer.new()
        descriptionSizer = Wx::HBoxSizer.new()

        namePanel = Wx::Panel.new(leftPanel, -1)
        descriptionPanel = Wx::Panel.new(leftPanel, -1)

        timeSlotNameText = Wx::StaticText.new(namePanel, -1, "Name:")
        @nameTextCtrl = Wx::TextCtrl.new(namePanel, -1, {size:Wx::Size.new(150, -1)})

        descriptionText = Wx::StaticText.new(descriptionPanel, -1, "Description:")
        @descriptionTextCtrl = Wx::TextCtrl.new(descriptionPanel, -1, {size:Wx::Size.new(150, 100), style:Wx::TE_MULTILINE|Wx::TE_NO_VSCROLL})
        @descriptionTextCtrl.set_max_length(200)

        nameSizer.add(timeSlotNameText, 0, Wx::ALL, 5)
        nameSizer.add_spacer(26)
        nameSizer.add(@nameTextCtrl, 0, Wx::ALL, 5)

        descriptionSizer.add(descriptionText, 0, Wx::ALL, 5)
        descriptionSizer.add(@descriptionTextCtrl, 0, Wx::ALL, 5)

        namePanel.set_sizer(nameSizer)
        descriptionPanel.set_sizer(descriptionSizer)

        nameSizer.fit(namePanel)
        descriptionSizer.fit(descriptionPanel)

        leftSizer.add(namePanel, 0, Wx::ALL, 5)
        leftSizer.add(descriptionPanel, 0, Wx::ALL, 5)

        leftPanel.set_sizer(leftSizer)

        leftSizer.fit(topPanel)

        rightSizer = Wx::VBoxSizer.new()
        rightPanel = Wx::Panel.new(topPanel, -1)

        startSizer = Wx::HBoxSizer.new()
        endSizer = Wx::HBoxSizer.new()

        startPanel = Wx::Panel.new(rightPanel, -1)
        endPanel = Wx::Panel.new(rightPanel, -1)

        startText = Wx::StaticText.new(startPanel, -1, "Start time:")
        $startCtrl = Wx::TextCtrl.new(startPanel, -1, "00", {size:Wx::Size.new(21, -1)})
        $startCtrl.set_max_length(2)

        startDividerText = Wx::StaticText.new(startPanel, -1, ":")
        $startCtrl2 = Wx::TextCtrl.new(startPanel, -1, "00", {size:Wx::Size.new(21, -1)})
        $startCtrl2.set_max_length(2)

        endText = Wx::StaticText.new(endPanel, -1, "End time:")
        $endCtrl = Wx::TextCtrl.new(endPanel, -1, "00", {size:Wx::Size.new(21, -1)})
        $endCtrl.set_max_length(2)

        endDividerText = Wx::StaticText.new(endPanel, -1, ":")
        $endCtrl2 = Wx::TextCtrl.new(endPanel, -1, "00", {size:Wx::Size.new(21, -1)})
        $endCtrl2.set_max_length(2)

        startSizer.add(startText, 0, Wx::LEFT|Wx::TOP|Wx::RIGHT, 5)
        startSizer.add($startCtrl, 0, Wx::LEFT||Wx::BOTTOM, 5)
        startSizer.add(startDividerText, 0, Wx::LEFT|Wx::BOTTOM, 5)
        startSizer.add($startCtrl2, 0, Wx::LEFT|Wx::BOTTOM, 5)


        endSizer.add(endText, 0, Wx::ALL, 5)
        endSizer.add_spacer(6)
        endSizer.add($endCtrl, 0, Wx::LEFT|Wx::BOTTOM, 5)
        endSizer.add(endDividerText, 0, Wx::LEFT|Wx::BOTTOM, 5)
        endSizer.add($endCtrl2, 0, Wx::LEFT|Wx::BOTTOM, 5)

        startPanel.set_sizer(startSizer)
        endPanel.set_sizer(endSizer)
        startSizer.fit(startPanel)
        endSizer.fit(endPanel)

        rightSizer.add(startPanel, 0, Wx::ALL, 5)
        rightSizer.add(endPanel, 0, Wx::ALL, 5)
        rightPanel.set_sizer(rightSizer)
        rightSizer.fit(topPanel)

        topSizer.add(leftPanel)
        topSizer.add(rightPanel)
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

        bottomSizer.add(okButton, 0, Wx::LEFT, 100)
        bottomSizer.add_spacer(30)
        bottomSizer.add(cancelButton, 0, Wx::ALL, 0)
        bottomPanel.set_sizer(bottomSizer)
        bottomSizer.fit(fullPanel)

        fullSizer.add(topPanel, 0, Wx::ALL, 5)
        fullSizer.add(bottomPanel, 0, Wx::BOTTOM, 10)
        fullPanel.set_sizer(fullSizer)
        fullSizer.fit(self)

        if dialogType == "Edit"
            evt_button(okButton) { edit() }
            selection = @listCtrl.get_selections()[0]
            if selection == nil
                return
            end

            @nameTextCtrl.set_value(@listCtrl.get_item(selection, 0).get_text())
            @descriptionTextCtrl.set_value(@timeSlotDescription[selection])

            time1 = @listCtrl.get_item(selection, 1).get_text().split(":")
            time2 = @listCtrl.get_item(selection, 2).get_text().split(":")

            $startCtrl.set_value(time1[0])
            $startCtrl2.set_value(time1[1])
            $endCtrl.set_value(time2[0])
            $endCtrl2.set_value(time2[1])
        end
    end

    def add()
        name = @nameTextCtrl.get_value()
        description = @descriptionTextCtrl.get_value()

        begin
            start1 = Integer $startCtrl.get_value()
            start2 = Integer $startCtrl2.get_value()
        rescue
            message = Wx::MessageDialog.new(@listCtrl, "incorrect Start Time", {style:Wx::ICON_ERROR})
            message.show_modal()
            return
        end

        begin
            end1 = Integer $endCtrl.get_value()
            end2 = Integer $endCtrl2.get_value()
        rescue
            message = Wx::MessageDialog.new(@listCtrl, "incorrect End Time", {style:Wx::ICON_ERROR})
            message.show_modal()
            return
        end

        if name == ""
            message = Wx::MessageDialog.new(@listCtrl, "Name is needed", {style:Wx::ICON_ERROR})
            message.show_modal()
            return
        elsif start1 < 0 or start1 > 24
            message = Wx::MessageDialog.new(@listCtrl, "incorrect Start time", {style:Wx::ICON_ERROR})
            message.show_modal()
            return
        elsif start2 < 0 or start2 > 59
            message = Wx::MessageDialog.new(@listCtrl, "incorrect Start time", {style:Wx::ICON_ERROR})
            message.show_modal()
            return
        elsif end1 < 0 or end1 > 24
            message = Wx::MessageDialog.new(@listCtrl, "incorrect End time", {style:Wx::ICON_ERROR})
            message.show_modal()
            return
        elsif end2 < 0 or end2 > 59
            message = Wx::MessageDialog.new(@listCtrl, "incorrect End time", {style:Wx::ICON_ERROR})
            message.show_modal()
            return
        end

        start1 = start1.to_s()
        start2 = start2.to_s()
        end1 = end1.to_s()
        end2 = end2.to_s()

        if start1.length == 1
            start1 = "0#{start1}"
        end
        if start2.length == 1
            start2 = "#{start2}0"
        end
        if end1.length == 1
            end1 = "0#{end1}"
        end
        if end2.length == 1
            end2 = "#{end2}0"
        end

        $startTime = "#{start1}:#{start2}:00"
        $endTime = "#{end1}:#{end2}:00"

        query = "INSERT INTO time_slots (id, time_slot, description, start_time, end_time) VALUES (NULL, '#{name}', '#{description}', '#{$startTime}', '#{$endTime}')"
        execQuery(query)


        index = @listCtrl.get_item_count()

        if index == 0
            @ids[0] = 1
            @timeSlotDescription[0] = description
        else
            @ids[@ids.length()] = @ids[index-1] + 1
        end
        @timeSlotDescription[index] = description
        listItem = Wx::ListItem.new()

        listItem.set_id(index)
        listItem.set_text(name)

        @listCtrl.insert_item(listItem)

        @listCtrl.set_item(index, 1, $startTime)
        @listCtrl.set_item(index, 2, $endTime)

        $colorIndex = 1
        for i in 0..@listCtrl.get_item_count() - 1
            @listCtrl.set_item_background_colour(i, changingColor())
        end

        self.destroy()
    end

    def edit()
        begin
            start1 = Integer $startCtrl.get_value()
            start2 = Integer $startCtrl2.get_value()
        rescue
            message = Wx::MessageDialog.new(@listCtrl, "incorrect Start Time", {style:Wx::ICON_ERROR})
            message.show_modal()
            return
        end

        begin
            end1 = Integer $endCtrl.get_value()
            end2 = Integer $endCtrl2.get_value()
        rescue
            message = Wx::MessageDialog.new(@listCtrl, "incorrect End Time", {style:Wx::ICON_ERROR})
            message.show_modal()
            return
        end

        if name == ""
            message = Wx::MessageDialog.new(@listCtrlt, "Name is needed", {style:Wx::ICON_ERROR})
            message.show_modal()
            return
        elsif start1 < 0 or start1 > 24
            message = Wx::MessageDialog.new(@listCtrl, "incorrect Start time", {style:Wx::ICON_ERROR})
            message.show_modal()
            return
        elsif start2 < 0 or start2 > 59
            message = Wx::MessageDialog.new(@listCtrl, "incorrect Start time", {style:Wx::ICON_ERROR})
            message.show_modal()
            return
        elsif end1 < 0 or end1 > 24
            message = Wx::MessageDialog.new(@listCtrl, "incorrect End time", {style:Wx::ICON_ERROR})
            message.show_modal()
            return
        elsif end2 < 0 or end2 > 59
            message = Wx::MessageDialog.new(@listCtrl, "incorrect End time", {style:Wx::ICON_ERROR})
            message.show_modal()
            return
        end

        name = @nameTextCtrl.get_value()
        description = @descriptionTextCtrl.get_value()
        id = @ids[@selected]

        start1 = start1.to_s()
        start2 = start2.to_s()
        end1 = end1.to_s()
        end2 = end2.to_s()

        if start1.length == 1
            start1 = "0#{start1}"
        end
        if start2.length == 1
            start2 = "#{start2}0"
        end
        if end1.length == 1
            end1 = "0#{end1}"
        end
        if end2.length == 1
            end2 = "#{end2}0"
        end

        $startTime = "#{start1}:#{start2}:00"
        $endTime = "#{end1}:#{end2}:00"

        query = "UPDATE shifts SET time_slots = '#{name}', description = '#{description}', start_time = '#{$startTime}', end_time = '#{$endTime}' WHERE id = #{id}"
        execQuery(query)

        @listCtrl.set_item(@selected, 0, name)
        @listCtrl.set_item(@selected, 1, $startTime)
        @listCtrl.set_item(@selected, 2, $endTime)

        @timeSlotDescription[@selected] = description

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


