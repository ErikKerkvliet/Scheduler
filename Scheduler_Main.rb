
require 'wx'
require 'mysql'

require_relative 'Scheduler_Globalvar'
require_relative 'Scheduler_TimeSlotPanel'
require_relative 'Scheduler_QualificationPanel'
require_relative 'Scheduler_CertificatePanel'
require_relative 'Scheduler_PersonnelPanel'
require_relative 'Scheduler_ProjectPanel'
require_relative 'Scheduler_DB'

class CreateListCtrl < Wx::ListCtrl
    def initialize(parent, position, size)
        super( parent, getId(), position, size, {style:Wx::LC_REPORT | Wx::RA_SPECIFY_COLS | Wx::LC_SINGLE_SEL});

    end
end

class CreatePanel < Wx::Panel
    def initialize(parent, position)
        super( parent, getId(), {pos: position, style: Wx::SIMPLE_BORDER});

    end
end

class MyApp < Wx::App
    @lesson_id
    @data
    @teacher_class
    @class_lessons

    def on_init()
        begin
            $connection = Scheduler_Globalvar.getConnection()

            @teacher_class = {}

            query = "SELECT name AS rows FROM classes WHERE class_year=1"
            #out = execQuery(query)
            #row_amount = out.num_rows


            for year in 1..1#row_amount+1
                @data = []
                @lesson_id = -1
                @class_lessons = {}
                mainQuery = "SELECT class_id, school_year, classes.class_year, class_name, abbreviation AS teacher, qualification as lesson, duration, times_a_week,
     times_a_day FROM (SELECT class_id, school_year, class_year, class_name, abbreviation, qualification FROM (
    SELECT class_id, school_year, class_year, class_name, abbreviation, teacher_id FROM (
    SELECT class_years AS class_id, school_year, class_year, class_name, teacher_id FROM (
    SELECT (@cnt := @cnt + 1) AS class_years, t.id, t.school_year, t.class_year, t.class_name FROM (
    SELECT id, school_year, class_year, name AS class_name FROM classes WHERE school_year='2014/2015') AS t CROSS JOIN (SELECT @cnt := 0) AS dummy)
     AS class LEFT JOIN classes_teachers ON classes_teachers.class_id=class.id) AS class LEFT JOIN teachers ON class.teacher_id=teachers.id) AS teachers
     LEFT JOIN (SELECT teacher_id, qualification FROM (SELECT teacher_id, qualification_id FROM (SELECT teacher_id, id FROM (
    SELECT certificate_id, teacher_id FROM teachers LEFT JOIN teachers_certificates ON teachers.id=teachers_certificates.teacher_id)
     AS teachers LEFT JOIN certificates ON teachers.certificate_id=certificates.id) as certificate LEFT JOIN certificates_qualifications ON
     certificate.id=certificates_qualifications.certificate_id) AS qualification_ids LEFT JOIN qualifications ON
    qualification_ids.qualification_id=qualifications.id) AS qualifications ON teachers.teacher_id=qualifications.teacher_id WHERE class_id=#{year})
     AS classes LEFT JOIN times ON classes.class_year=times.class_year WHERE classes.qualification=times.lesson"


                @data[0] = {"class_id"=>"1", "school_year"=>"2014/2015", "class_year"=>"1", "class_name"=>"1a", "teacher"=>"Tf", "lesson"=>"en", "duration"=>"50", "times_a_week"=>3, "times_a_day"=>1, "times_left"=>3}
                @data[1] = {"class_id"=>"1", "school_year"=>"2014/2015", "class_year"=>"1", "class_name"=>"1a", "teacher"=>"Be", "lesson"=>"ne", "duration"=>"50", "times_a_week"=>3, "times_a_day"=>1, "times_left"=>3}
                @data[2] = {"class_id"=>"1", "school_year"=>"2014/2015", "class_year"=>"1", "class_name"=>"1a", "teacher"=>"Kp", "lesson"=>"lo", "duration"=>"50", "times_a_week"=>2, "times_a_day"=>2, "times_left"=>2}
                @data[3] = {"class_id"=>"1", "school_year"=>"2014/2015", "class_year"=>"1", "class_name"=>"1a", "teacher"=>"No", "lesson"=>"na", "duration"=>"50", "times_a_week"=>2, "times_a_day"=>1, "times_left"=>2}
                @data[4] = {"class_id"=>"1", "school_year"=>"2014/2015", "class_year"=>"1", "class_name"=>"1a", "teacher"=>"Zg", "lesson"=>"fa", "duration"=>"50", "times_a_week"=>3, "times_a_day"=>1, "times_left"=>3}
                @data[5] = {"class_id"=>"1", "school_year"=>"2014/2015", "class_year"=>"1", "class_name"=>"1a", "teacher"=>"Br", "lesson"=>"sk", "duration"=>"50", "times_a_week"=>2, "times_a_day"=>1, "times_left"=>2}
                @data[6] = {"class_id"=>"1", "school_year"=>"2014/2015", "class_year"=>"1", "class_name"=>"1a", "teacher"=>"Ba", "lesson"=>"wi", "duration"=>"50", "times_a_week"=>3, "times_a_day"=>1, "times_left"=>3}
                @data[7] = {"class_id"=>"1", "school_year"=>"2014/2015", "class_year"=>"1", "class_name"=>"1a", "teacher"=>"My", "lesson"=>"ak", "duration"=>"50", "times_a_week"=>2, "times_a_day"=>1, "times_left"=>2}
                @data[8] = {"class_id"=>"1", "school_year"=>"2014/2015", "class_year"=>"1", "class_name"=>"1a", "teacher"=>"Bl", "lesson"=>"ec", "duration"=>"50", "times_a_week"=>2, "times_a_day"=>1, "times_left"=>2}
                @data[9] = {"class_id"=>"1", "school_year"=>"2014/2015", "class_year"=>"1", "class_name"=>"1a", "teacher"=>"Pi", "lesson"=>"gs", "duration"=>"50", "times_a_week"=>3, "times_a_day"=>1, "times_left"=>3}
                @data[10] = {"class_id"=>"1", "school_year"=>"2014/2015", "class_year"=>"1", "class_name"=>"1a", "teacher"=>"Zu", "lesson"=>"bv", "duration"=>"50", "times_a_week"=>2, "times_a_day"=>2, "times_left"=>2}
                @data[11] = {"class_id"=>"1", "school_year"=>"2014/2015", "class_year"=>"1", "class_name"=>"1a", "teacher"=>"Mm", "lesson"=>"du", "duration"=>"50", "times_a_week"=>3, "times_a_day"=>1, "times_left"=>3}
                @data[12] = {"class_id"=>"1", "school_year"=>"2014/2015", "class_year"=>"1", "class_name"=>"1a", "teacher"=>"Be", "lesson"=>"lob", "duration"=>"50", "times_a_week"=>1, "times_a_day"=>1, "times_left"=>1}
                @data[13] = {"class_id"=>"1", "school_year"=>"2014/2015", "class_year"=>"1", "class_name"=>"1a", "teacher"=>"Si", "lesson"=>"mu", "duration"=>"50", "times_a_week"=>1, "times_a_day"=>1, "times_left"=>1}

               # query = execQuery(mainQuery)
                for i in 0..13#query.num_rows - 1
                    #@data[i] = query.fetch_hash()

                    teacher = @data[i]["teacher"]
                    #if @teacher_class == {}
                        init_teacher_class(teacher)
                    #end

                    @data[i]["times_left"] = @data[i]["times_a_week"].to_i
                    @data[i]["times_a_week"] =  @data[i]["times_a_week"].to_i
                    @data[i]["times_a_day"] = @data[i]["times_a_day"].to_i

                    p @data[i]
                end

                class_name = @data[0]['class_name']
                @class_lessons = init_class_lessons(class_name)

                hour = 0
                lessons = 0
                until $LESSONS_A_DAY - 1 < hour
                    p "hour #{hour}"

                    day = 0
                    until $DAYS_A_WEEK - 1 < day
                        p "day #{day}"
                        nr = for_lesson(hour, day, class_name)
                        if lessons == @data.length
                            hour = $LESSONS_A_DAY
                            break
                        end
                        if nr == 0
                            lessons += 1
                            @lesson_id +=1
                        elsif nr == 1
                            lessons = 0
                            @lesson_id += 1

                            day += 1
                        end

                    end

                    hour += 1
                end
            end
        end
        exit(0)
    end

    def for_lesson(hour, day, class_name)
        if @lesson_id >= @data.length - 1
            @lesson_id = 0
        end

        return 0 if @data[@lesson_id]['times_left'] == 0

        teacher = @teacher_class.keys[@lesson_id]

        return 0 if @teacher_class[teacher][hour][day] != ""

        lesson = @data[@lesson_id]['lesson']

        if @data[@lesson_id]['times_a_day'] > 1

        end

        return 0 if @class_lessons[class_name][day].include?(lesson)

        @class_lessons[class_name][day][hour] = lesson
        @teacher_class[teacher][day][hour] = class_name

        @data[@lesson_id]['times_left'] -= 1
        
        return 1
    end

    def init_class_lessons(class_name)
        @class_lessons[class_name] = []

        for hour in 0..($LESSONS_A_DAY - 1)
            @class_lessons[class_name][hour] = []

            for day in 0..($DAYS_A_WEEK - 1)
                @class_lessons[class_name][hour][day] = ""
            end
        end

        return @class_lessons
    end

    def init_teacher_class(teacher)
        for rows in 0..@data.length - 1
            @teacher_class[teacher] = []

            for hour in 0..($LESSONS_A_DAY - 1)
                @teacher_class[teacher][hour] = []

                for day in 0..($DAYS_A_WEEK - 1)
                    @teacher_class[teacher][hour][day] = ""
                end
            end
        end

        return @teacher_class
    end
end

app = MyApp.new()
app.main_loop

