require_relative "Scheduler_QualificationPanel"

class CertificateDialog < Wx::Dialog
    @nameTextCtrl = nil
    @descriptions = nil
    @descriptionTextCtrl = nil
    @listCtrl = nil
    
    def initialize(parent, listCtrl, title, dialogType)
        super(parent, Wx::ID_ANY, title, {size:[500, 500]})
        begin
        @listCtrl = listCtrl
        @descriptions = parent.descriptions
        @ids = parent.ids
        @selected = parent.selected

        set_background_colour($BGCOLOR)

        topSizer = Wx::HBoxSizer.new()
        topPanel = Wx::Panel.new(self, -1)

        leftPanel = Wx::Panel.new(topPanel, -1)
        leftSizer = Wx::VBoxSizer.new()

        nameSizer = Wx::HBoxSizer.new()
        namePanel = Wx::Panel.new(leftPanel, -1)
        nameText = Wx::StaticText.new(namePanel, -1, "Name:")
        nameCtrl = Wx::TextCtrl.new(namePanel, -1, {size:Wx::Size.new(150, -1)})
        nameCtrl.set_max_length(20)

        companySizer = Wx::HBoxSizer.new()
        companyPanel = Wx::Panel.new(leftPanel, -1)
        companyText = Wx::StaticText.new(companyPanel, -1, "Company:")
        companyCtrl = Wx::TextCtrl.new(companyPanel, -1, {size:Wx::Size.new(150, -1)})

        descriptionSizer = Wx::HBoxSizer.new()
        descriptionPanel = Wx::Panel.new(leftPanel, -1)
        descriptionText = Wx::StaticText.new(descriptionPanel, -1, "Description:")
        descriptionCtrl = Wx::TextCtrl.new(descriptionPanel, -1, {size:Wx::Size.new(150, 100), style:Wx::TE_MULTILINE|Wx::TE_NO_VSCROLL})
        descriptionCtrl.set_max_length(200)

        nameSizer.add(nameText, 0, Wx::ALL, 8)
        nameSizer.add_spacer(26)
        nameSizer.add(nameCtrl, 0, Wx::ALL, 5)
        namePanel.set_sizer(nameSizer)
        nameSizer.fit(leftPanel)

        companySizer.add(companyText, 0, Wx::ALL, 8)
        companySizer.add_spacer(8)
        companySizer.add(companyCtrl, 0, Wx::ALL, 5)
        companyPanel.set_sizer(companySizer)
        companySizer.fit(leftPanel)

        descriptionSizer.add(descriptionText, 0, Wx::ALL, 8)
        descriptionSizer.add(descriptionCtrl, 0, Wx::ALL, 5)
        descriptionPanel.set_sizer(descriptionSizer)
        descriptionSizer.fit(leftPanel)

        qualificationPanel = Wx::Panel.new(topPanel, -1)
        qualificationSizer = Wx::VBoxSizer.new()
        givenQualificationsText = Wx::StaticText.new(qualificationPanel, -1, "Given qualifications")
        p @ids, @selected
        query = "SELECT * FROM qualifications WHERE id IN (SELECT qualification_id FROM certificates_qualifications WHERE certificate_id = #{@ids[@selected]} )"

        if @ids[@selected] == nil
            qualificationList = QualificationPanel.new(self, "", false)
        else
            qualificationList = QualificationPanel.new(self, query, false)
        end

        leftSizer.add(namePanel, 0, Wx::ALL, 5)
        leftSizer.add(companyPanel, 0, Wx::ALL, 5)
        leftSizer.add(descriptionPanel, 0, Wx::ALL, 5)

        leftPanel.set_sizer(leftSizer)
        leftSizer.fit(leftPanel)

        rightSizer = Wx::HBoxSizer.new()
        rightPanel = Wx::Panel.new(topPanel, -1)

        rightRightSizer = Wx::VBoxSizer.new()
        rightRightPanel = Wx::Panel.new(rightPanel, -1)

        browsePanel = Wx::Panel.new(rightRightPanel, -1)
        browseSizer = Wx::HBoxSizer.new()
        browseText = Wx::StaticText.new(browsePanel, -1, "Image:")
        pathButton = Wx::Button.new(browsePanel, -1, "Browse")

        file = "img/no image.jpg"
        img = Wx::Image.new(file)

        img = img.size(Wx::Size.new(img.get_width(), img.get_height()), Wx::Point.new(0, 0),  Wx::IMAGE_QUALITY_NORMAL)
        img = img.scale(100, 100)
        img = img.convert_to_bitmap()
        imgPanel = Wx::Panel.new(rightRightPanel, -1, {size:[img.get_width(), img.get_height()], style:Wx::SUNKEN_BORDER})
        imgPanel.set_background_colour(Wx::WHITE)

        bitmap = Wx::StaticBitmap.new(imgPanel, -1, img)

        evt_button(pathButton) { browse(imgPanel, bitmap) }

        browseSizer.add(browseText, 0, Wx::ALL, 5)
        browseSizer.add(pathButton, 0, Wx::ALL, 0)

        browsePanel.set_sizer(browseSizer)
        browseSizer.fit(browsePanel)

        rightRightSizer.add(imgPanel, 0, Wx::ALL, 0)
        rightRightSizer.add(browsePanel, 0, Wx::ALL, 5)

        rightRightPanel.set_sizer(rightRightSizer)
        rightRightSizer.fit(rightRightPanel)

        topSizer.add(leftPanel, 0, Wx::ALL, 5)
        topSizer.add(qualificationList, 0, Wx::ALL, 5)
        topSizer.add(rightPanel, 0, Wx::ALL, 5)

        topPanel.set_sizer(topSizer)
        topSizer.fit(topPanel)
        rescue => e
            p e
        end

    end

    def browse(parent, bitmap)
        img = Wx::Image.new("img/no image.jpg")
        img = img.convert_to_bitmap()
        bitmap.set_bitmap(img)

        fileDialog = Wx::FileDialog.new(self, "Select an image")
        if fileDialog.show_modal() == Wx::ID_OK
            file = fileDialog.get_path()
        end

        img = Wx::Image.new(file)
        imgWidth = img.get_width()
        imgHeight = img.get_height()

        img = img.size(Wx::Size.new(imgWidth, imgHeight), Wx::Point.new(0, 0),  Wx::IMAGE_QUALITY_NORMAL)

        imgWidth = imgWidth.round(2)
        imgHeight = imgHeight.round(2)

        if imgWidth/imgHeight <= 1
            imgWidth = (100 * imgWidth/imgHeight).to_i
            imgHeight = 100
        else
            imgHeight = (100 * imgHeight/imgWidth).to_i
            imgWidth = 100
        end
        img = img.scale(imgWidth, imgHeight)
        img = img.convert_to_bitmap()

        bitmap.set_bitmap(img)

    end

    def add()
        self.destroy()
    end

    def edit()
        self.destroy()
    end

    def cancel()
        self.destroy()
    end
end