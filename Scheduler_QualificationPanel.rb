require_relative 'Scheduler_QualificationDialog'

class CreateListItem <  Wx::ListItem
    def initialize
        super
        super.set_background_colour(changingColor())
    end
end

class QualificationPanel < Wx::Panel
    attr_accessor :ids, :qualificationDescription, :selected
    @listCtrl = nil
    @hooverItem = -1
    @selected = -1

    def initialize(parent, mainQuery, bottomButtons=true)
        @ids = []
        @qualificationDescription = []

        super(parent, -1)

        set_background_colour($BGCOLOR)

        topSizer = Wx::HBoxSizer.new()

        listCtrlSizer = Wx::VBoxSizer.new()

        listCtrlPanel = Wx::Panel.new(self, Wx::ID_ANY)
        listCtrlPanel.set_background_colour($BGCOLOR)

        @listCtrl = 12342
        @listCtrl = Wx::ListCtrl.new(listCtrlPanel, -1 , {style:Wx::LC_REPORT | Wx::RA_SPECIFY_COLS | Wx::LC_SINGLE_SEL, size:Wx::Size.new(154, 150)})
        @listCtrl.insert_column(0, "Qualification")

        @listCtrl.set_column_width(0, 150)

        query = execQuery(mainQuery)
        $colorIndex = 1

        query.each_hash { |h|
            index = @listCtrl.get_item_count()

            @ids[index] = h['id'].to_i

            @qualificationDescription[index] = h['description']

            listItem = CreateListItem.new()
            listItem.set_id(index)

            listItem.set_text(h['qualification'])

            @listCtrl.insert_item(listItem)
        }
        @listCtrl.evt_left_dclick{|event| on_list_item_dClick()}
        @listCtrl.evt_leave_window(){|event| on_leave_window()}
        @listCtrl.evt_motion(){|event| mouse_over(event)}

        evt_list_item_selected(@listCtrl.get_id()){|event| on_list_item_selected()}

        @descriptionText = Wx::TextCtrl.new(listCtrlPanel, -1, "", {style:Wx::NO_BORDER|Wx::TE_MULTILINE|Wx::TE_NO_VSCROLL, size:Wx::Size.new(150, 200)})
        @descriptionText.set_background_colour($BGCOLOR)

        listCtrlSizer.add(@listCtrl, 0, Wx::ALL, 5)
        listCtrlSizer.add_spacer(5)
        listCtrlSizer.add(@descriptionText, 0, Wx::LEFT, 10)

        listCtrlPanel.set_sizer(listCtrlSizer)

        listCtrlSizer.fit(listCtrlPanel)

        buttonSizer = Wx::VBoxSizer.new()

        buttonPanel = Wx::Panel.new(self, -1)

        addButton = Wx::Button.new(buttonPanel,  Wx::ID_ANY, "add", {size:Wx::Size.new(60, 20)})
        editButton = Wx::Button.new(buttonPanel,  Wx::ID_ANY, "edit", {size:Wx::Size.new(60, 20)})
        removeButton = Wx::Button.new(buttonPanel, Wx::ID_ANY, "remove", {size:Wx::Size.new(60, 20)})

        evt_button(addButton) { clicked('add') }
        evt_button(editButton) { clicked('edit') }
        evt_button(removeButton) { clicked('remove') }

        buttonSizer.add_spacer(5)

        buttonSizer.add(addButton, 1, Wx::ALL, 5)
        buttonSizer.add(editButton, 1, Wx::ALL, 5)
        buttonSizer.add(removeButton, 1, Wx::ALL, 5)

        buttonPanel.set_sizer(buttonSizer)

        buttonSizer.fit(buttonPanel)

        topSizer.add(listCtrlPanel, 0, Wx::ALL, 5);
        if bottomButtons == false
            topSizer.add(buttonPanel, 0, Wx::ALL, 5);
            buttonPanel.show(false)
        else
            topSizer.add(buttonPanel, 0, Wx::ALL, 5);
        end

        set_sizer(topSizer)

        topSizer.fit(self)
    end

    def clearList()
        @listCtrl.delete_all_items()
    end

    def refillList(query)
        @listCtrl.delete_all_items()

        query = execQuery(query)
        $colorIndex = 1
        @ids = []
        @qualificationDescription = []
        query.each_hash { |h|
            index = @listCtrl.get_item_count()

            @ids[index] = h['id'].to_i

            @qualificationDescription[index] = h['description']

            listItem = CreateListItem.new()
            listItem.set_id(index)

            listItem.set_text(h['qualification'])

            @listCtrl.insert_item(listItem)
        }
    end

    def on_list_item_selected()
        @selected = @listCtrl.get_selections()[0]
    end

    def on_list_item_dClick()
        dialog = QualificationDialog.new(self, @listCtrl, "Edit Qualification", "Edit")
        dialog.show()
    end

    def clicked(label)
        @selected = @listCtrl.get_selections()[0]
        if label == "add"
            dialog = QualificationDialog.new(self, @listCtrl, "Add Qualification", "Add")
            dialog.show()
        elsif label == "edit"
            if  @selected != nil
                dialog = QualificationDialog.new(self, @listCtrl,"Edit Qualification", "Edit")
                dialog.show()
            end
        elsif label == "remove"

            query = "DELETE FROM qualifications WHERE id = #{@ids[@selected]}"
            execQuery(query)

            @listCtrl.delete_item(@selected)
            @ids[@selected] = nil

            @ids = @ids.compact()

            @qualificationDescription[@selected] = nil
            @qualificationDescription = @qualificationDescription.compact()

            $colorIndex = 1
            for i in 0..@listCtrl.get_item_count() - 1
                @listCtrl.set_item_background_colour(i, changingColor())
            end
        end
    end

    def mouse_over(event)
        mousePosition = event.get_position()

        item, flags = @listCtrl.hit_test(mousePosition)

        if item == -1
            @descriptionText.set_value("")
            @hooverItem = item
        elsif @hooverItem != item
            @descriptionText.set_value(@qualificationDescription[item])
            @hooverItem = item
        end
    end

    def on_leave_window()
        @descriptionText.set_value("")
    end
end

