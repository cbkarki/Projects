#setwd("C:/Users/chitr/OneDrive - University of Texas at El Paso/data_science/semesters/sem5-spring-2023/data visualization/final-project")

#setwd('/Users/chitr/Desktop/final-project')
dat = read.csv(file = "master.csv",header = T)


library(shiny)
library("tidyverse")
library(highcharter)
library("billboarder")
library(ggpubr)
library(webr)
library(plotly)


ui = fluidPage(

    titlePanel(strong("Exploring Food Pantery Data, UTEP")),
       navlistPanel(
                "Effects of Food Security on Students",
                 widths = c(2,10),
                br(),
        tabPanel("Research Question 1",
                 h4(strong("How is use of government federal aid/assistance associated with
                   food insecurity as measured by the USDA index or categories?")),
                 br(),
                 p("Below are the bar graphs and the donuts charts to demostrate the
                   different levels of food insecurity among the students receiving various
                   Federal Aids in the year 2022.The graphs are interactive and can be changed
                   to different year from the horizontal year bar."),
                 p("Among the participents of the survey, 54.7 % of students work and study.
                 Simillarly, 28.1% student are getting loans, 12.5% students received scholarship
                  and 4.7% students applied for emergency loans. In every group of students receiving
                  Federal Aid, majory of the students have food insecurity leve either very low or low.
                  only few students in each group have marginal food insecurity.Among the students, work
                  study group, there are more number of students with marginal food insecurity.
                   "),
                br(),
                 sliderInput("year", label = "Years",
                             min = 2019,
                             max = 2022,value = 2022 ),
                h4(strong("Federal Aid Vs Food Insecurity Among Students")),
                br(),
                 #selectInput("dataset", label = "Dataset")
                 splitLayout(cellWidths = c("70%", "30%"),
                             highchartOutput("plotbar"),
                             #plotOutput("piedonut")
                            billboarderOutput("bbdonut")

                 )

        ),

               tabPanel("Research Question 2",

                 h4(strong(" Does food insecurity (as measured by USDA index or categories)
                    have a relationship with the items pertaining to concentration on
                    school and degree progress/completion?")),
                 br(),
                 p("Graphs below shows the relations between food insecurity, students concentration and
                   the progress towards degree completion."),
                 p("There are 152 students who have delayed graduation by 2 semester or more and 144 students
                 delayed by 1 semester. No mater, students
                   belonging to low,marginal or very low food insecurity, think of delaying the graduation and they do
                   delay. Majority of the students who delayed think almost every day of delaying belong to the
                   very low food insecurity group.
                   It is intersting to observe that even  the students who never think of delaying
                   are delaying their graduation. There could other reason not associated with the food insecurity.
                   "),
                 br(),

                 h4(strong("Food Insecurity  Vs Concentration Vs Degree Completion among Students")),

                 splitLayout(cellWidths = c("60%","40%"),
                             highchartOutput("sankey2"),
                             highchartOutput("donut2")

                             )

        ),

        tabPanel("Research Question 3",
                 h4(strong("Are there gender or ethnicity differences in the items pertaining to
                        concentration on school and degree progress/completion?")),
                 br(),
                 p("Graphs below show the relationship between Gender, students concentration
                   and the progress towards degree completion"),
                 p("The number of female students who are delaying graduation are high in number
                   in comparision to other genders. Females who thing almost every day about delaying
                 and delayed in actual are a bit higher in comparision to others. "),

                 br(),

                 h4(strong("Gender Vs Concentration Vs Degree Completion among Students")),
                 splitLayout(cellWidths = c("50%","50%"),
                             highchartOutput("sankey3"),
                             plotOutput("ggbar3")
                             #plotlyOutput("ggbar3")
                 )
        )
    )
)



server = function(input, output) {
    output$plotbar = renderHighchart({
        dat %>%
            filter(Year==input$year) %>%
            select(FedAid,index) %>%
            drop_na() %>%
            filter(FedAid != "UTEP's COVID CARES Act Fund" & FedAid != "Other") %>%
            group_by(FedAid) %>%
            mutate(Index = ifelse(index==0|index==1,"Mariginal",
                                  ifelse(index==5|index==6,"Very Low","Low"))) %>%
            select(FedAid,Index) %>%
            table()  %>%
            as.data.frame() %>% arrange(desc(Freq)) %>%
            hchart('column', hcaes(x = 'FedAid', y = 'Freq', group = 'Index')) %>%
            hc_legend(
                align = "left",
                verticalAlign = "top",
                layout = "horizontal"
            ) %>%
            hc_xAxis(title = list(text="Federal Aid")) %>% hc_yAxis(title = list(text="#. of Students")) #%>%
           # hc_title(text = paste("Food Security levels in students with different Federal Aids (Year:",input$year,")"))



    })

     # output$piedonut = renderPlot({
     #     dat %>%
     #         filter(Year==input$year) %>%
     #         select(FedAid,index) %>%
     #         drop_na() %>%
     #         filter(FedAid != "UTEP's COVID CARES Act Fund" & FedAid != "Other") %>%
     #         mutate(Index = ifelse(index==0|index==1,"Mariginal",ifelse(index==5|index==6,"Very Low","Low"))) %>%
     #         group_by(FedAid,Index) %>% select(-index) %>% summarise(n=n()) %>%
     #         PieDonut(aes(FedAid, Index, count=n), title = "",
     #                  ratioByGroup = F,
     #                  #explode = c(5) ,  explodeDonut=TRUE
     #
     #         )
     # })

    output$bbdonut = renderBillboarder({
        dat %>%
            filter(Year==input$year) %>%
            select(FedAid,index) %>%
            drop_na() %>%
            filter(FedAid != "UTEP's COVID CARES Act Fund" & FedAid != "Other") %>%
            group_by(FedAid) %>%
            mutate(Index = ifelse(index==0|index==1,"Mariginal",
                                  ifelse(index==5|index==6,"Very Low","Low"))) %>%
            select(FedAid) %>% table() %>% data.frame() -> donut

            billboarder() %>%
            bb_donutchart(data = donut,title=paste("Federal Aids",input$year)) %>%
            bb_legend(show = TRUE)
    })

    output$sankey2 = renderHighchart({
        inner_join(q1,q2,"RespondentId") %>%
            select(-RespondentId) %>%
            drop_na() %>%
            mutate(Index = ifelse(index==0|index==1,"Mariginal",
                                  ifelse(index==5|index==6,"Very Low","Low"))) %>%
            select(Index,DiffConcentrate,DelayComplDegree)-> sankey2
        #group_by(Index,DiffConcentrate,DelayComplDegree)


        hchart(data_to_sankey(sankey2),type = "sankey")
    })

    output$donut2 = renderHighchart({
        q1 =   dat %>%
            filter(Year=="2022") %>%
            select(FedAid,index,RespondentId,Gender)
        dat2 = read.csv(file = "extra_questions_withID.csv",header = T)
        q2 = dat2 %>%
            select(RespondentId,DiffConcentrate,DelayComplDegree)


        inner_join(q1,q2,"RespondentId") %>%
            select(-RespondentId) %>%
            drop_na() %>%
            mutate(Index = ifelse(index==0|index==1,"Mariginal",
                                  ifelse(index==5|index==6,"Very Low","Low"))) %>%
            select(Index,DiffConcentrate,DelayComplDegree) %>%
            group_by(Index,DiffConcentrate,DelayComplDegree) %>%
            summarise(n=n()) -> piedo2

        #PieDonut(data = piedo2,aes(Index,DiffConcentrate, count=n), title = "hello",ratioByGroup = T,)

        dout2 = data_to_hierarchical(piedo2,c(Index,DiffConcentrate,DelayComplDegree),n)

        hchart(dout2,type="sunburst")
    })
    q1 =   dat %>%
        filter(Year=="2022") %>%
        select(FedAid,index,RespondentId,Gender)
    dat2 = read.csv(file = "extra_questions_withID.csv",header = T)
    q2 = dat2 %>%
        select(RespondentId,DiffConcentrate,DelayComplDegree)

    output$sankey3 = renderHighchart({
        q3 = dat2 %>%
            select(RespondentId,DiffConcentrate)
        gend = c("Female","Male","transgender","Gender variant","other","Prefere not to say")

        inner_join(q1,q2,"RespondentId") %>%
            #select(FedAid,Gender,DiffConcentrate) %>%
            filter(FedAid != "UTEP's COVID CARES Act Fund" & FedAid != "Other") %>%
            mutate(Index = ifelse(index==0|index==1,"Mariginal",ifelse(index==5|index==6,"Very Low","Low"))) %>% rename(Gen=Gender) %>%
            mutate(Gender = gend[as.numeric(Gen)] ) %>%
            select(Gender,DiffConcentrate,DelayComplDegree) -> sankey3

        hchart(data_to_sankey(sankey3),type = "sankey")

    })

    output$ggbar3 = renderPlot({
        gend = c("Female","Male","transgender","Gender variant","other","Prefere not to say")
        br3 = inner_join(q1,q2,"RespondentId") %>%
            #select(FedAid,Gender,DiffConcentrate) %>%
            filter(FedAid != "UTEP's COVID CARES Act Fund" & FedAid != "Other") %>%
            mutate(Index = ifelse(index==0|index==1,"Mariginal",ifelse(index==5|index==6,"Very Low","Low"))) %>%
            rename(Gen=Gender) %>%
            mutate(Gender = gend[as.factor(Gen)],
                   Gender = as.factor(Gender)) %>%
            data.frame() %>% drop_na()
            p <- ggplot(br3,aes(x=DelayComplDegree,fill=Gender))+
            geom_bar(stat = "count",
                     position = position_dodge( preserve = "single")) +
            facet_grid(DiffConcentrate~.) +
            theme_bw()+
            theme(legend.position = "top") +
            ylab("#. of Students")+
            theme(legend.title= element_blank()) +
                scale_fill_hue(l=40)
            p
            #ggplotly(p) %>% config(displayModeBar = F)

    })



}

shinyApp(ui,server)
