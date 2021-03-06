drop table if exists zone_beat_id cascade;

create table zone_beat_id as (
	with zone_beats as (
		select distinct
			trim(both ' ' from zone_beat) as zone_beat
		from 
			raw_911_response
		where
			event_clearance_description = 'MOTOR VEHICLE COLLISION'
	)
	, beats as (
		select distinct
			trim(both ' ' from zone_beat) as zone_beat
			, hundred_block_location
		from
			raw_911_response
		where
			event_clearance_date != ' '
			and event_clearance_code in ('430', '460')
	)
	, new_beats as (
		select
			zone_beat
			, sum(case when hundred_block_location like '%/%' then 1 else 0 end) as intersections
		from
			beats
		group by 
			zone_beat
	)
	select
		zb.zone_beat as category
		, row_number() over (order by zb.zone_beat) as id
		, nb.intersections
	from
		zone_beats as zb
		left join
		new_beats as nb
			on zb.zone_beat = nb.zone_beat
)
;

drop table if exists condition_id cascade;

create table condition_id as (
	with condition_list as (
		select distinct
			conditions
			, case
				when conditions like '%Snow%' then 'Snow'
				when conditions like '%Rain%' or conditions like '%Drizzle%' then 'Rain'
				when conditions like '%Fog%' 
					or conditions like '%Smoke%'
					or conditions like '%Haze%' then 'Fog'
				when conditions like '%Thunderstorm%' then 'Thunderstorm'
				when conditions like '%Cloud%'
					or conditions like '%Overcast%' then 'Cloudy'
				else 'Others'
			end as category
		from
			weather
	)
	, category_list as (
		select distinct
			case
				when conditions like '%Snow%' then 'Snow'
				when conditions like '%Rain%' or conditions like '%Drizzle%' then 'Rain'
				when conditions like '%Fog%' 
					or conditions like '%Smoke%'
					or conditions like '%Haze%' then 'Fog'
				when conditions like '%Thunderstorm%' then 'Thunderstorm'
				when conditions like '%Cloud%'
					or conditions like '%Overcast%' then 'Cloudy'
				else 'Others'
			end as category
		from
			weather
	)
	, category_list2 as (
		select 
			category
			, row_number() over (order by category) as id
		from
			category_list
	)
	select 
		con.conditions as category
		, cat.id
	from
		condition_list as con
		join
		category_list2 as cat
			on con.category = cat.category
)
;

drop table if exists winddir_id cascade;

create table winddir_id as (
	with winddirs as (
		select distinct
			winddir
		from
			weather
	)
	select
		winddir as category
		, row_number() over (order by winddir) as id
	from
		winddirs
)
;