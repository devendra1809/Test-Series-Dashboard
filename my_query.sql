select h.Y_M,h.course_id,b.title as Course_Name,b.Status,d.name as Category,h.test_series_id,g.test_series_name,b.Type,h.Lang_Used,h.test_series_marks,h.Total_Attempt,h.AVG_Marks,
h.33P,h.34_50,h.51_70,h.71_100,
h.Total_Res,h.AVG_Rating

from

(select Date_Format(Attempt_Date,'%Y-%m-%d') as Y_M,d.course_id,d.test_series_id,d.Lang_Used,d.test_series_marks,
count(distinct d.user_id) as Total_Attempt,avg(d.marks) as AVG_Marks,
count(case when d.result<=33 then d.user_id end) as '33P',
count(case when d.result>=34 and d.result<=50 then d.user_id end) as '34_50',
count(case when d.result>=51 and d.result<=70 then d.user_id end) as '51_70',
count(case when d.result>=71 and d.result<=100 then d.user_id end) as '71_100',
count(distinct e.user_id) as Total_Res,avg(e.rating) as AVG_Rating

from

(select
user_id,course_id,test_series_id,result,marks,test_series_marks,
(total_test_series_time-time_remain)*100/total_test_series_time as Sub_time,
(case when lang_used=1 then 'English' else 'Hindi' end) as Lang_Used,
my_rank,
DATE(FROM_UNIXTIME(creation_time + (5 * 3600) + (30 * 60))) as Attempt_Date
from course_test_series_report
where state=1
and result_type=1
and first_attempt=1
and DATE_FORMAT(FROM_UNIXTIME(creation_time + (5 * 3600) + (30 * 60)),'%Y-%m')>=DATE_FORMAT(DATE_SUB(CURDATE(),INTERVAL 3 MONTH),'%Y-%m')
and course_id not in (1880,16685,17503)) d

left join

(select user_id,course_id,video_id,rating,DATE(FROM_UNIXTIME(created + (5 * 3600) + (30 * 60))) as Rating_Date
from video_rating
where type=1
and DATE_FORMAT(FROM_UNIXTIME(created + (5 * 3600) + (30 * 60)),'%Y-%m')>=DATE_FORMAT(DATE_SUB(CURDATE(),INTERVAL 3 MONTH),'%Y-%m')
and rating not in (0,6,41)
and course_id not in (1880,16685,17503)) e
on d.user_id=e.user_id and d.course_id=e.course_id and d.test_series_id=e.video_id and d.Attempt_Date=e.Rating_Date
group by 1,2,3,4,5) h

inner join (select id,title,publish,(case when course_sp>0 then 'Paid' else 'Free' end) as Status,
(case when id<>'6960' and title like '%Test%' then 'Test_Series' else 'Courses' end) as 'Type' from course_master
) b on h.course_id=b.id
inner join (select course_id,main_cat,sub_cat from course_meta) c on b.id=c.course_id
inner join (select id,name from course_stream_name_master_report)  d on d.id=c.main_cat
inner join (SELECT id,test_series_name,(case when test_series_name like '%Quiz%' then 'Quiz' else 'Test_Paper' end) as 'Type'  FROM course_test_series_master) AS g ON h.test_series_id = g.id

order by 4 desc,3 desc,1 desc,7 desc,5 desc