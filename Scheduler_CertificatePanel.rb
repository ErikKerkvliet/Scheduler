require_relative "Scheduler_QualificationPanel"
require_relative "Scheduler_CertificateDialog"

class CreateListItem <  Wx::ListItem
    def initialize
        super
        super.set_background_colour(changingColor())
    end
end

class CertificatePanel < Wx::Panel
    attr_accessor :ids, :descriptions, :selected, :qualificationPanel
    @listCtrl = nil
    @hooverItem = -1
    @qualificationPanel = nil
    @selected = -1

    def initialize(parent, mainQuery, bottomButtons = true)
        @ids = []
        @certificateNames = []
        @descriptions = []

        super(parent, -1)
        set_background_colour($BGCOLOR)

        topSizer = Wx::HBoxSizer.new()

        listCtrlSizer = Wx::VBoxSizer.new()

        listCtrlPanel = Wx::Panel.new(self,-1)
        listCtrlPanel.set_background_colour($BGCOLOR)

        @listCtrl = Wx::ListCtrl.new(listCtrlPanel, -1 , {style:Wx::LC_REPORT | Wx::RA_SPECIFY_COLS | Wx::LC_SINGLE_SEL, size:Wx::Size.new(154, 150)})
        @listCtrl.insert_column(0, "Certificate")

        query = execQuery(mainQuery)
        $colorIndex = 1
        query.each_hash { |h|
            index = @listCtrl.get_item_count()
            @ids[index] = h['id'].to_i

            @descriptions[index] = h['description']
            @certificateNames[index] = h['certificate']

            listItem = CreateListItem.new()
            listItem.set_id(index)

            listItem.set_text(@certificateNames[index])

            @listCtrl.insert_item(listItem)
        }
        @listCtrl.set_column_width(0, 150)
        @listCtrl.evt_left_dclick(){|event| on_list_item_dClick()}
        @listCtrl.evt_leave_window(){|event| on_leave_window(event)}
        @listCtrl.evt_motion(){|event| mouse_over(event)}
        evt_list_item_selected(@listCtrl.get_id()){|event| on_list_item_selected()}
        evt_list_item_deselected(@listCtrl.get_id()){|event| }

        @descriptionStaticText = Wx::TextCtrl.new(listCtrlPanel, -1, "", {style:Wx::NO_BORDER|Wx::TE_MULTILINE|Wx::TE_NO_VSCROLL, size:Wx::Size.new(254, 50)})
        @descriptionStaticText.set_background_colour($BGCOLOR)

        listCtrlSizer.add(@listCtrl, 0, Wx::ALL, 5)
        listCtrlSizer.add_spacer(5)
        listCtrlSizer.add(@descriptionStaticText, 0, Wx::LEFT, 10)

        listCtrlPanel.set_sizer(listCtrlSizer)

        listCtrlSizer.fit(listCtrlPanel)

        buttonSizer = Wx::VBoxSizer.new()

        buttonPanel = Wx::Panel.new(self, Wx::ID_ANY, {size:Wx::Size.new(100,200)})
        buttonPanel.set_background_colour($BGCOLOR)

        addButton = Wx::Button.new(buttonPanel,  Wx::ID_ANY, "add certificate", {size:Wx::Size.new(100, 20)})
        editButton = Wx::Button.new(buttonPanel,  Wx::ID_ANY, "edit certificate", {size:Wx::Size.new(100, 20)})
        removeButton = Wx::Button.new(buttonPanel, Wx::ID_ANY, "remove certificate", {size:Wx::Size.new(100, 20)})

        evt_button(addButton) { clicked( 'add') }
        evt_button(editButton) { clicked('edit') }
        evt_button(removeButton) { clicked('remove') }

        buttonSizer.add_spacer(5)

        buttonSizer.add(addButton, 1, Wx::ALL, 5)
        buttonSizer.add(editButton, 1, Wx::ALL, 5)
        buttonSizer.add(removeButton, 1, Wx::ALL, 5)

        buttonPanel.set_sizer(buttonSizer)

        buttonSizer.fit(buttonPanel)

        qualificationQuery = "SELECT * FROM qualifications"

        topSizer.add(listCtrlPanel, 0, Wx::ALL, 5);

        @qualificationPanel = (QualificationPanel.new(self, qualificationQuery, false))
        @qualificationPanel.clearList()
        
        topSizer.add(@qualificationPanel, 0, Wx::ALL, 0);
        if bottomButtons == false
            topSizer.add(buttonPanel, 0, Wx::ALL, 5);
            buttonPanel.show(false)
        else
            topSizer.add(buttonPanel, 0, Wx::ALL, 5);
        end

        set_sizer(topSizer)
        topSizer.fit(self)


    end

    def clicked(label)
        if  @selected == -1
           return
       end

        if label == "add"
                dialog = CertificateDialog.new(self, @listCtrl, "Add Certificate", "Add")
                dialog.show()
        elsif label == "edit"
            if  @selected != nil
                dialog = CertificateDialog.new(self, @listCtrl,"Edit Certificate", "Edit")
                dialog.show()
            end
        elsif label == "remove"

            query = "DELETE FROM shifts WHERE id = #{@ids[@selected]}"
            execQuery(query)

            @listCtrl.delete_item(@selected)
            @ids[@selected] = nil
            @ids = @ids.compact()

            @descriptions[@selected] = nil
            @descriptions = @descriptions.compact()

            $colorIndex = 1
            for i in 0..@listCtrl.get_item_count() - 1
                @listCtrl.set_item_background_colour(i, changingColor())
            end
        end
    end

    def on_list_item_selected()
        @selected = @listCtrl.get_selections()[0]
        @qualificationPanel.refillList("SELECT * FROM qualifications WHERE id IN (SELECT qualification_id FROM certificates_qualifications WHERE certificate_id = #{@ids[@selected]})")
        @listCtrl.set_item_background_colour(@selected, Wx::Colour.new("#7DAFFF"))
        @listCtrl.get_item(1)
    end

    def on_list_item_dClick()
        dialog = dialog.new(self, @listCtrl, "Edit Time Slot", "Edit")
        dialog.show()
    end

    def on_leave_window(evt)
        @descriptionStaticText.set_value("")
    end

    def mouse_over(evt)
        mousePosition = evt.get_position()

        item, flags = @listCtrl.hit_test(mousePosition)
        p @ids, item
        if item == -1
            @descriptionStaticText.set_value("")
            @hooverItem = item
        elsif @hooverItem != item
            @descriptionStaticText.set_value(@descriptions[item])

            @hooverItem = item
        end
    end
end
