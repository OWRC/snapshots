

## must run main.R




# Chloride
q.shallow <- "SELECT L.LOC_ID, L.INT_ID, SAM_ID, NAME, 
              INTERVAL_NAME, ALTERNATE_INTERVAL_NAME, READING_GROUP_NAME, 
              INT_TYPE, PARAMETER, VALUE, UNIT, QUALIFIER, MDL, UNCERTAINTY, 
              SCREEN_GEOL_UNIT, SAMPLE_DATE, RD_NAME_CODE
              FROM V_GEN_LAB AS L
              JOIN R_READING_GROUP_CODE AS G ON G.READING_GROUP_CODE = L.GROUP_CODE
              JOIN (SELECT * FROM D_INTERVAL_FORM_ASSIGN_FINAL
                    JOIN V_SYS_GEOL_UNIT_SHALLOW ON ASSIGNED_UNIT = GEOL_UNIT_CODE) AS Z ON L.INT_ID = Z.INT_ID
              WHERE PARAMETER LIKE 'Chloride'
              AND UNIT LIKE 'mg/L'
              AND VALUE > 0.1
              AND VALUE < 20000"

q.deep <- "SELECT L.LOC_ID, L.INT_ID, SAM_ID, NAME, 
            INTERVAL_NAME, ALTERNATE_INTERVAL_NAME, READING_GROUP_NAME, 
            INT_TYPE, PARAMETER, VALUE, UNIT, QUALIFIER, MDL, UNCERTAINTY, 
            SCREEN_GEOL_UNIT, SAMPLE_DATE, RD_NAME_CODE
            FROM V_GEN_LAB AS L
            JOIN R_READING_GROUP_CODE AS G ON G.READING_GROUP_CODE = L.GROUP_CODE
            JOIN (SELECT * FROM D_INTERVAL_FORM_ASSIGN_FINAL
                  JOIN V_SYS_GEOL_UNIT_DEEP ON ASSIGNED_UNIT = GEOL_UNIT_CODE) AS Z ON L.INT_ID = Z.INT_ID
            WHERE PARAMETER LIKE 'Chloride'
            AND UNIT LIKE 'mg/L'
            AND VALUE > 0.1
            AND VALUE < 20000"

df1 <- dbGetQuery(con,q.shallow) 
df2 <- dbGetQuery(con,q.deep) 
# print(length(unique(df1$LOC_NAME))==length(df1$LOC_NAME))
# View(df1)

p1 <- create.histogram.with.modelled.distribution(df1) + labs(tag="A)")
p2 <- create.histogram.with.modelled.distribution(df2) + labs(tag="B)")


g <- arrangeGrob(p1, p2, ncol=2)
ggsave("md/gwqual-chloride.png", g, width = 30, height = 10, units = "cm")




