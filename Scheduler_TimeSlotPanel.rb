require_relative 'Scheduler_TimeSlotDialog'

class CreateListItem <  Wx::ListItem
    def initialize
        super
        super.set_background_colour(changingColor())
    end
end

class TimeSlotPanel < Wx::Panel
    attr_accessor :ids, :timeSlotDescription, :timeSlotName, :selected
    @listCtrl = nil
    @hooverItem = -1
    @selected = -1

    def initialize(parent, mainQuery, bottomButtons = true)
        @ids = []
        @timeSlotName = []
        @timeSlotDescription = []

        super(parent, -1)

        set_background_colour($BGCOLOR)
        topSizer = Wx::HBoxSizer.new()

        listCtrlSizer = Wx::VBoxSizer.new()

        listCtrlPanel = Wx::Panel.new(self,-1)
        listCtrlPanel.set_background_colour($BGCOLOR)

        @listCtrl = Wx::ListCtrl.new(listCtrlPanel, -1 , {style:Wx::LC_REPORT | Wx::RA_SPECIFY_COLS | Wx::LC_SINGLE_SEL, size:Wx::Size.new(264, 150)})
        @listCtrl.insert_column(0, "Name")
        @listCtrl.insert_column(1, "Start time")
        @listCtrl.insert_column(2, "End time")

        @listCtrl.set_column_width(0, 100)

        query = execQuery(mainQuery)
        $colorIndex = 1
        query.each_hash { |h|
            index = @listCtrl.get_item_count()
            @ids[index] = h['id'].to_i

            @timeSlotDescription[index] = h['description']
            @timeSlotName[index] = h['time_slot']

            listItem = CreateListItem.new()
            listItem.set_id(index)

            listItem.set_text(h['name'])

            @listCtrl.insert_item(listItem)

            @listCtrl.set_item(index, 1, h['start_time'])
            @listCtrl.set_item(index, 2, h['end_time'])
        }

        @listCtrl.evt_left_dclick(){|event| on_list_item_dClick()}
        @listCtrl.evt_leave_window(){|event| on_leave_window(event)}
        @listCtrl.evt_motion(){|event| mouse_over(event)}

        evt_list_item_selected(@listCtrl.get_id()){|event| on_list_item_selected()}

        @timeSlotDescriptionStaticText = Wx::TextCtrl.new(listCtrlPanel, -1, "", {style:Wx::NO_BORDER|Wx::TE_MULTILINE|Wx::TE_NO_VSCROLL, size:Wx::Size.new(254, 50)})
        @timeSlotDescriptionStaticText.set_background_colour($BGCOLOR)

        listCtrlSizer.add(@listCtrl, 0, Wx::ALL, 5)
        listCtrlSizer.add_spacer(5)
        listCtrlSizer.add(@timeSlotDescriptionStaticText, 0, Wx::LEFT, 10)

        listCtrlPanel.set_sizer(listCtrlSizer)

        listCtrlSizer.fit(listCtrlPanel)

        buttonSizer = Wx::VBoxSizer.new()

        buttonPanel = Wx::Panel.new(self, Wx::ID_ANY, {size:Wx::Size.new(100,200)})
        buttonPanel.set_background_colour($BGCOLOR)

        addButton = Wx::Button.new(buttonPanel,  Wx::ID_ANY, "add", {size:Wx::Size.new(60, 20)})
        editButton = Wx::Button.new(buttonPanel,  Wx::ID_ANY, "edit", {size:Wx::Size.new(60, 20)})
        removeButton = Wx::Button.new(buttonPanel, Wx::ID_ANY, "remove", {size:Wx::Size.new(60, 20)})

        evt_button(addButton) { clicked( 'add') }
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

        mainQuery = "SELECT * FROM time_slots WHERE id IN (SELECT time_slot_id FROM sub_project_time_slots WHERE subproject_id = #{id})"
        query = execQuery(mainQuery)
        $lessons = []
        arrayCount = 0
        days = []
        query.each_hash { |h|
            $lessons[arrayCount] = []

            $lessons[arrayCount][0] = h['id'].to_i
            $lessons[arrayCount][1] = h['time_slot'].to_s
            $lessons[arrayCount][2] = h['duration'].to_i
            $lessons[arrayCount][3] = h['times_a_day'].to_i
            $lessons[arrayCount][4] = h['times_a_week'].to_i

            arrayCount += 1
        }

        $teachers = []
        $time_lots = []
        mainQuery = "SELECT * FROM teachers"



        query = execQuery(mainQuery)
        for i in 0..query.num_rows - 1
            $teachers[i] = query.fetch_hash()
        end

        mainQuery = "SELECT * FROM time_slots"
        query = execQuery(mainQuery)
        for i in 0..query.num_rows - 1
            $time_lots[i] = query.fetch_hash()
        end

    end

    def on_list_item_dClick()
        dialog = TimeSlotDialog.new(self, @listCtrl, "Edit Time Slot", "Edit")
        dialog.show()
    end

    def on_list_item_selected()
        @selected = @listCtrl.get_selections()[0]
    end

    def clicked(label)
        if label == "add"
            dialog = TimeSlotDialog.new(self, @listCtrl, "Add Time Slot", "Add")
            dialog.show()
        elsif label == "edit"
            if  @selected != nil
                dialog = TimeSlotDialog.new(self, @listCtrl,"Edit Time Slot", "Edit")
                dialog.show()
            end
        elsif label == "remove"

            query = "DELETE FROM time_slots WHERE id = #{@ids[@selected]}"
            execQuery(query)

            @listCtrl.delete_item(@selected)
            @ids[@selected] = nil
            @ids = @ids.compact()

            @timeSlotDescription[@selected] = nil
            @timeSlotDescription = @timeSlotDescription.compact()

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
            @timeSlotDescriptionStaticText.set_value("")
            $timeSlotItem = item
        elsif $timeSlotItem != item
            @timeSlotDescriptionStaticText.set_value(@timeSlotDescription[item])
            $timeSlotItem = item
        end
    end

    def on_leave_window(evt)
        @timeSlotDescriptionStaticText.set_value("")
    end
end



