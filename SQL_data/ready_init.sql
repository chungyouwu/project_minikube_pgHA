--
-- PostgreSQL database cluster dump
--

SET default_transaction_read_only = off;

SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;

--
-- Roles
--

CREATE ROLE abel;
ALTER ROLE abel WITH NOSUPERUSER INHERIT NOCREATEROLE NOCREATEDB LOGIN NOREPLICATION NOBYPASSRLS PASSWORD 'SCRAM-SHA-256$4096:6FYx6RCMlB+iSLS6n0C6uA==$X9k0fMEotW7PCv/P/bywp29UGrUBYrRrfqZFyoYxF8M=:j5Ix64qMjJ2VU6sDr3VsjXVlxRAta5F0k9xe2kNRyRc=';
CREATE ROLE chung;
ALTER ROLE chung WITH NOSUPERUSER INHERIT NOCREATEROLE NOCREATEDB LOGIN NOREPLICATION NOBYPASSRLS PASSWORD 'SCRAM-SHA-256$4096:Hh5GWwKvSiFm1SWjIIzZCg==$420/D5GtfE7alUQRxdA0+D3J4NivWeStm65nGJNGh5E=:oqO/Eg9o+i7o22w+Xn/N0rJCsDJQmFr/FQbWVbObNO8=';
CREATE ROLE postgres;
ALTER ROLE postgres WITH SUPERUSER INHERIT CREATEROLE CREATEDB LOGIN REPLICATION BYPASSRLS PASSWORD 'SCRAM-SHA-256$4096:Mh5solgZehWOORPjMQg5jg==$gKdDWdVkjicHo49qhUYeZ45/5aC508/2/lX5MBVNpvg=:q9SHyYtgkAXCDqWoSHgpOmMT+s/6LMYV8T4rIZWxZAA=';
CREATE ROLE replication;
ALTER ROLE replication WITH NOSUPERUSER INHERIT NOCREATEROLE NOCREATEDB LOGIN REPLICATION NOBYPASSRLS PASSWORD 'SCRAM-SHA-256$4096:aawowI2wkzf2GX5sIinRLw==$hXvulazWKCP0TwzTzu/Sa/2vd4+9KNF2lvhwP6BVBzg=:mPqHKQs7pzoMss+9pvh2ontBE2yu4gvURZC49EDcv1Q=';

--
-- User Configurations
--








--
-- Databases
--

--
-- Database "template1" dump
--

\connect template1

--
-- PostgreSQL database dump
--

-- Dumped from database version 16.3 (Debian 16.3-1.pgdg120+1)
-- Dumped by pg_dump version 16.3 (Debian 16.3-1.pgdg120+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- PostgreSQL database dump complete
--

--
-- Database "postgres" dump
--

\connect postgres

--
-- PostgreSQL database dump
--

-- Dumped from database version 16.3 (Debian 16.3-1.pgdg120+1)
-- Dumped by pg_dump version 16.3 (Debian 16.3-1.pgdg120+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: pg_buffercache; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_buffercache WITH SCHEMA public;


--
-- Name: EXTENSION pg_buffercache; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_buffercache IS 'examine the shared buffer cache';


--
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA public;


--
-- Name: EXTENSION pg_stat_statements; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_stat_statements IS 'track planning and execution statistics of all SQL statements executed';


--
-- Name: bank_region; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.bank_region AS ENUM (
    'north',
    'south',
    'unknown'
);


ALTER TYPE public.bank_region OWNER TO postgres;

--
-- Name: payby; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.payby AS ENUM (
    'credit card',
    'debit card',
    'cash',
    'transfer'
);


ALTER TYPE public.payby OWNER TO postgres;

--
-- Name: account_cred_tg_fn(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.account_cred_tg_fn() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
INSERT INTO account_cred_his(old_password, new_password) 
VALUES(OLD.password, NEW.password);
RETURN NEW;
END $$;


ALTER FUNCTION public.account_cred_tg_fn() OWNER TO postgres;

--
-- Name: transfer_funds(integer, integer, numeric, character varying, public.payby); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.transfer_funds(IN m_from integer, IN m_to integer, IN amount numeric, IN reason character varying DEFAULT NULL::character varying, IN method public.payby DEFAULT 'cash'::public.payby)
    LANGUAGE plpgsql
    AS $$
DECLARE
account_num int;
BEGIN
  select count(*) into account_num from account_information where account_id in (m_from, m_to);
  if account_num = 2 then 
    raise notice 'both account exist, transaction starting...';
    update account_information set balance=balance - amount where account_id = m_from;
    update account_information set balance=balance + amount where account_id = m_to;
    insert into account_info_trans_history(trans_sourceid,trans_amount,trans_targetid, trans_reason, trans_method) 
    values(m_from,amount,m_to, reason, method);
        
  else 
    raise exception 'One of the accounts does not exist';
    
  end if;
END$$;


ALTER PROCEDURE public.transfer_funds(IN m_from integer, IN m_to integer, IN amount numeric, IN reason character varying, IN method public.payby) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: account_cred_his; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.account_cred_his (
    his_id integer NOT NULL,
    his_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    old_password character varying(50),
    new_password character varying(50)
);


ALTER TABLE public.account_cred_his OWNER TO postgres;

--
-- Name: account_cred_his_his_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.account_cred_his_his_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.account_cred_his_his_id_seq OWNER TO postgres;

--
-- Name: account_cred_his_his_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.account_cred_his_his_id_seq OWNED BY public.account_cred_his.his_id;


--
-- Name: account_credentials; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.account_credentials (
    account_id integer,
    password character varying(50) NOT NULL
);


ALTER TABLE public.account_credentials OWNER TO postgres;

--
-- Name: account_info_trans_history; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.account_info_trans_history (
    trans_id integer NOT NULL,
    trans_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    trans_sourceid integer NOT NULL,
    trans_amount numeric(15,2) NOT NULL,
    trans_targetid integer NOT NULL,
    trans_reason character varying(30),
    trans_method public.payby
);


ALTER TABLE public.account_info_trans_history OWNER TO postgres;

--
-- Name: account_info_trans_history_trans_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.account_info_trans_history_trans_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.account_info_trans_history_trans_id_seq OWNER TO postgres;

--
-- Name: account_info_trans_history_trans_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.account_info_trans_history_trans_id_seq OWNED BY public.account_info_trans_history.trans_id;


--
-- Name: account_information; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.account_information (
    account_id integer NOT NULL,
    user_id integer,
    bank_id integer,
    bank_region public.bank_region,
    balance numeric(15,2),
    opendate date
);


ALTER TABLE public.account_information OWNER TO postgres;

--
-- Name: account_information_account_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.account_information_account_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.account_information_account_id_seq OWNER TO postgres;

--
-- Name: account_information_account_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.account_information_account_id_seq OWNED BY public.account_information.account_id;


--
-- Name: bankbranches; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.bankbranches (
    bank_id integer NOT NULL,
    bank_region public.bank_region NOT NULL,
    bank_name character varying(20) NOT NULL,
    account_num integer NOT NULL,
    total_funds numeric(15,2) NOT NULL
)
PARTITION BY LIST (bank_region);


ALTER TABLE public.bankbranches OWNER TO postgres;

--
-- Name: user_information; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_information (
    user_id integer NOT NULL,
    name character varying(100) NOT NULL,
    gender character(1),
    phone character varying(15),
    email character varying(100)
);


ALTER TABLE public.user_information OWNER TO postgres;

--
-- Name: account_view; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.account_view AS
 SELECT ui.name,
    bb.bank_name,
    ai.balance
   FROM ((public.user_information ui
     JOIN public.account_information ai ON ((ai.user_id = ui.user_id)))
     JOIN public.bankbranches bb ON ((bb.bank_id = ai.bank_id)));


ALTER VIEW public.account_view OWNER TO postgres;

--
-- Name: bankbranches_bank_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.bankbranches_bank_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.bankbranches_bank_id_seq OWNER TO postgres;

--
-- Name: bankbranches_bank_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.bankbranches_bank_id_seq OWNED BY public.bankbranches.bank_id;


--
-- Name: bankbranches_default; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.bankbranches_default (
    bank_id integer DEFAULT nextval('public.bankbranches_bank_id_seq'::regclass) NOT NULL,
    bank_region public.bank_region NOT NULL,
    bank_name character varying(20) NOT NULL,
    account_num integer NOT NULL,
    total_funds numeric(15,2) NOT NULL
);


ALTER TABLE public.bankbranches_default OWNER TO postgres;

--
-- Name: bankbranches_north; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.bankbranches_north (
    bank_id integer DEFAULT nextval('public.bankbranches_bank_id_seq'::regclass) NOT NULL,
    bank_region public.bank_region NOT NULL,
    bank_name character varying(20) NOT NULL,
    account_num integer NOT NULL,
    total_funds numeric(15,2) NOT NULL
);


ALTER TABLE public.bankbranches_north OWNER TO postgres;

--
-- Name: bankbranches_south; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.bankbranches_south (
    bank_id integer DEFAULT nextval('public.bankbranches_bank_id_seq'::regclass) NOT NULL,
    bank_region public.bank_region NOT NULL,
    bank_name character varying(20) NOT NULL,
    account_num integer NOT NULL,
    total_funds numeric(15,2) NOT NULL
);


ALTER TABLE public.bankbranches_south OWNER TO postgres;

--
-- Name: marketsurvey; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.marketsurvey (
    survey_id integer NOT NULL,
    survey_title character varying(30) NOT NULL,
    survey_des character varying(200),
    survey_response jsonb
);


ALTER TABLE public.marketsurvey OWNER TO postgres;

--
-- Name: marketsurvey_survey_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.marketsurvey_survey_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.marketsurvey_survey_id_seq OWNER TO postgres;

--
-- Name: marketsurvey_survey_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.marketsurvey_survey_id_seq OWNED BY public.marketsurvey.survey_id;


--
-- Name: user_information_user_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.user_information_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.user_information_user_id_seq OWNER TO postgres;

--
-- Name: user_information_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.user_information_user_id_seq OWNED BY public.user_information.user_id;


--
-- Name: bankbranches_default; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bankbranches ATTACH PARTITION public.bankbranches_default DEFAULT;


--
-- Name: bankbranches_north; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bankbranches ATTACH PARTITION public.bankbranches_north FOR VALUES IN ('north');


--
-- Name: bankbranches_south; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bankbranches ATTACH PARTITION public.bankbranches_south FOR VALUES IN ('south');


--
-- Name: account_cred_his his_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_cred_his ALTER COLUMN his_id SET DEFAULT nextval('public.account_cred_his_his_id_seq'::regclass);


--
-- Name: account_info_trans_history trans_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_info_trans_history ALTER COLUMN trans_id SET DEFAULT nextval('public.account_info_trans_history_trans_id_seq'::regclass);


--
-- Name: account_information account_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_information ALTER COLUMN account_id SET DEFAULT nextval('public.account_information_account_id_seq'::regclass);


--
-- Name: bankbranches bank_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bankbranches ALTER COLUMN bank_id SET DEFAULT nextval('public.bankbranches_bank_id_seq'::regclass);


--
-- Name: marketsurvey survey_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.marketsurvey ALTER COLUMN survey_id SET DEFAULT nextval('public.marketsurvey_survey_id_seq'::regclass);


--
-- Name: user_information user_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_information ALTER COLUMN user_id SET DEFAULT nextval('public.user_information_user_id_seq'::regclass);


--
-- Data for Name: account_cred_his; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.account_cred_his (his_id, his_time, old_password, new_password) FROM stdin;
\.


--
-- Data for Name: account_credentials; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.account_credentials (account_id, password) FROM stdin;
1	0499
2	3792
3	2885
4	2574
5	5034
6	5496
7	8671
8	3994
9	7962
10	6433
11	8562
12	0972
13	1453
14	1094
15	5697
16	3271
17	0399
18	2837
19	2452
20	6809
21	2787
22	9446
23	5395
24	2860
25	8591
26	1928
27	0165
28	3997
29	5266
30	0663
31	4670
32	9511
33	3189
34	3696
35	7388
36	1327
37	7787
38	5842
39	1286
40	4690
41	8106
42	2640
43	0033
44	4347
45	5925
46	3294
47	6249
48	9640
49	0654
50	1865
51	2582
52	1620
53	8109
54	2230
55	8985
56	3558
57	7537
58	3216
59	4836
60	9175
61	0429
62	2560
63	7518
64	5539
65	3046
66	9016
67	9836
68	3632
69	6769
70	4688
71	8369
72	4540
73	3464
74	3263
75	3208
76	5801
77	6348
78	2667
79	0550
80	8491
81	2685
82	7026
83	8828
84	2923
85	8619
86	4663
87	3789
88	4412
89	4321
90	9922
91	3897
92	9914
93	1150
94	5198
95	7584
96	0142
97	0436
98	6726
99	3423
100	7230
101	6214
102	0441
103	0064
104	0128
105	5604
106	9862
107	7678
108	3231
109	5578
110	0463
111	4403
112	0025
113	0097
114	5439
115	0134
116	7127
117	1782
118	4625
119	6266
120	5706
121	3480
122	6427
123	2670
124	5587
125	1896
126	5683
127	0692
128	6958
129	8721
130	9767
131	6153
132	6160
133	8430
134	6289
135	4317
136	1831
137	5541
138	4015
139	2938
140	1329
141	8065
142	3306
143	5684
144	1449
145	3844
146	0845
147	7278
148	7711
149	5022
150	1258
151	4829
152	5335
153	2267
154	8187
155	6823
156	2305
157	0416
158	7404
159	1459
160	1579
161	0331
162	8777
163	0692
164	7602
165	4645
166	5394
167	9919
168	5074
169	0561
170	3386
171	3250
172	3418
173	6622
174	7843
175	3914
176	4525
177	7840
178	2092
179	8103
180	4673
181	1257
182	7433
183	0365
184	7765
185	2031
186	8708
187	2762
188	0466
189	9947
190	3223
191	9016
192	2487
193	6215
194	9180
195	7889
196	8317
197	3125
198	5869
199	0891
200	1191
201	6950
202	1466
203	6346
204	3593
205	5820
206	0236
207	6090
208	3452
209	2812
210	4380
211	6178
212	0860
213	2263
214	5415
215	8782
216	8030
217	0159
218	2045
219	5420
220	3371
221	8264
222	6209
223	4895
224	7399
225	8708
226	8292
227	1258
228	1016
229	0515
230	8448
231	8625
232	7611
233	0909
234	6665
235	1500
236	8425
237	8450
238	0955
239	1762
240	7736
241	7109
242	6835
243	6868
244	5537
245	7706
246	6454
247	7562
248	8224
249	1879
250	4737
251	1047
252	5551
253	5536
254	0928
255	2896
256	4296
257	4939
258	4219
259	8613
260	0856
261	6462
262	7789
263	5036
264	2972
265	4288
266	2747
267	5391
268	1980
269	5544
270	5517
271	0141
272	7718
273	1181
274	8634
275	2187
276	5959
277	5270
278	4487
279	0984
280	4374
281	3128
282	3773
283	5573
284	3697
285	6805
286	5315
287	3461
288	7764
289	6542
290	1428
291	6457
292	6493
293	3569
294	0405
295	5724
296	0982
297	1090
298	3176
299	9321
300	0238
301	9856
302	9038
303	6929
304	1748
305	7041
306	6873
307	4789
308	2416
309	4286
310	8604
311	8507
312	9121
313	1710
314	7439
315	2737
316	6223
317	6147
318	3336
319	4562
320	0647
321	6914
322	2935
323	9507
324	1615
325	2727
326	0451
327	7809
328	3185
329	0470
330	9424
331	9699
332	4009
333	7044
334	9004
335	4089
336	5449
337	1285
338	5540
339	3762
340	1012
341	2195
342	1664
343	6954
344	7180
345	4875
346	4863
347	9064
348	7108
349	3820
350	1167
351	5744
352	1608
353	2554
354	3987
355	9202
356	4962
357	8454
358	6768
359	5757
360	1771
361	0600
362	7567
363	5691
364	4890
365	6403
366	5621
367	2590
368	7905
369	9808
370	4515
371	4697
372	2118
373	9770
374	9946
375	5281
376	2617
377	0788
378	2792
379	2053
380	5335
381	8905
382	3062
383	2134
384	8189
385	1192
386	8254
387	8826
388	9465
389	4198
390	3475
391	1089
392	3856
393	7687
394	2524
395	8698
396	2101
397	4594
398	4238
399	7500
400	2458
401	3634
402	6362
403	4599
404	8904
405	7131
406	5383
407	7624
408	7639
409	6280
410	7613
411	7809
412	1341
413	9475
414	9647
415	5581
416	5615
417	2500
418	4550
419	4762
420	6622
421	1130
422	2161
423	2129
424	8850
425	6493
426	2804
427	6926
428	2415
429	1873
430	6902
431	9351
432	0509
433	5101
434	8996
435	6715
436	4017
437	7780
438	9154
439	8986
440	3335
441	2894
442	4262
443	7311
444	6492
445	4707
446	5786
447	4196
448	0059
449	5922
450	5659
451	6604
452	5954
453	8335
454	0975
455	2922
456	1722
457	0483
458	5356
459	7111
460	8634
461	9785
462	6811
463	4932
464	1920
465	8994
466	9470
467	5846
468	6860
469	6053
470	7151
471	6546
472	9986
473	5073
474	0105
475	8047
476	5083
477	3839
478	0142
479	9095
480	7521
481	9210
482	5590
483	9008
484	7306
485	4438
486	6885
487	0788
488	9571
489	7025
490	3042
491	1179
492	1755
493	1486
494	9076
495	7941
496	7759
497	1153
498	0166
499	3431
500	3920
501	5509
502	2509
503	0211
504	5735
505	6266
506	9634
507	2200
508	4354
509	4360
510	5638
511	1065
512	5036
513	7691
514	5618
515	6913
516	2420
517	8399
518	5699
519	5961
520	7777
521	0914
522	1660
523	1219
524	0315
525	3662
526	8035
527	4683
528	6349
529	1973
530	2326
531	3523
532	0216
533	5259
534	4148
535	7278
536	7318
537	7923
538	3365
539	0522
540	1603
541	6495
542	6376
543	4162
544	5253
545	2901
546	2106
547	3953
548	9090
549	9997
550	0738
551	6327
552	1012
553	9802
554	9431
555	2268
556	1319
557	3345
558	0538
559	1228
560	2031
561	0485
562	6460
563	3350
564	5938
565	4303
566	9041
567	0861
568	9145
569	2442
570	8578
571	0105
572	4565
573	9243
574	3500
575	4775
576	1982
577	9044
578	8530
579	1562
580	1737
581	8021
582	0130
583	7383
584	8469
585	3519
586	8502
587	9332
588	4880
589	8190
590	4195
591	9991
592	2257
593	6491
594	5777
595	8025
596	1993
597	1381
598	8865
599	9016
600	1166
601	7349
602	0689
603	1488
604	2048
605	8826
606	1625
607	7338
608	8506
609	2921
610	2501
611	0336
612	8189
613	9891
614	3742
615	1503
616	1379
617	2570
618	6719
619	9232
620	1109
621	7508
622	9703
623	5753
624	7085
625	1641
626	9962
627	9861
628	5893
629	3087
630	6182
631	2306
632	4776
633	9178
634	3916
635	3240
636	7033
637	5531
638	7890
639	7619
640	9921
641	8442
642	4645
643	8579
644	1949
645	6418
646	0291
647	8807
648	6425
649	6614
650	9393
651	5935
652	5680
653	3591
654	8905
655	9123
656	5868
657	0349
658	8021
659	9647
660	5916
661	8696
662	6288
663	6646
664	6618
665	2454
666	6034
667	4036
668	2474
669	7027
670	5211
671	7944
672	5803
673	5769
674	3597
675	0064
676	0183
677	5391
678	0488
679	7493
680	3451
681	6181
682	9627
683	0334
684	3290
685	4510
686	7819
687	9919
688	7755
689	9626
690	6923
691	7439
692	2740
693	1857
694	9713
695	2458
696	5421
697	7129
698	3866
699	6122
700	8307
701	0413
702	6280
703	3799
704	2252
705	9410
706	5134
707	5294
708	0225
709	9341
710	6656
711	6155
712	9577
713	1901
714	3573
715	9204
716	1273
717	2738
718	3165
719	4235
720	3451
721	6365
722	1864
723	3445
724	1126
725	7999
726	4118
727	7063
728	0242
729	0559
730	1225
731	0225
732	7775
733	4074
734	8811
735	8883
736	0006
737	1398
738	1135
739	5093
740	0376
741	0628
742	4904
743	3007
744	5657
745	8457
746	3523
747	4431
748	9310
749	4877
750	2646
751	8366
752	5187
753	3122
754	2157
755	6360
756	0604
757	9400
758	6586
759	2482
760	9979
761	9180
762	5754
763	0653
764	2946
765	6552
766	0769
767	2612
768	2899
769	8435
770	1636
771	2963
772	5286
773	8919
774	0918
775	7516
776	2037
777	4955
778	9924
779	7832
780	3713
781	4929
782	0825
783	2230
784	8011
785	8779
786	6951
787	9223
788	0873
789	6304
790	7636
791	2104
792	6102
793	3441
794	0263
795	1918
796	4748
797	7816
798	7378
799	5522
800	3721
801	7035
802	9549
803	9934
804	1159
805	9959
806	1241
807	6715
808	3045
809	2572
810	4110
811	4565
812	1717
813	7755
814	9422
815	0563
816	7532
817	9217
818	2689
819	7496
820	1659
821	4474
822	8190
823	2412
824	6164
825	0661
826	7778
827	6612
828	2478
829	7930
830	5526
831	1349
832	3985
833	7276
834	9794
835	0561
836	3017
837	1605
838	3380
839	3114
840	1879
841	8631
842	3412
843	0910
844	6819
845	9777
846	7785
847	8569
848	7947
849	4345
850	2873
851	4611
852	8104
853	6011
854	7989
855	4075
856	8313
857	4572
858	1190
859	6920
860	1555
861	7303
862	7562
863	0710
864	5523
865	6845
866	3428
867	4383
868	9191
869	6666
870	0872
871	6866
872	6989
873	3459
874	1020
875	8773
876	2271
877	7493
878	5988
879	4391
880	8283
881	1519
882	6681
883	2700
884	2376
885	4170
886	3076
887	7282
888	6872
889	2954
890	3181
891	1631
892	0774
893	1849
894	1594
895	1527
896	3048
897	4803
898	1229
899	6436
900	1936
901	9512
902	2585
903	3168
904	9839
905	1246
906	9049
907	9326
908	3595
909	3363
910	5687
911	0590
912	3800
913	5474
914	8219
915	6999
916	9310
917	7487
918	6919
919	6545
920	9555
921	3119
922	7369
923	0904
924	3669
925	8525
926	4699
927	2698
928	9639
929	9630
930	1379
931	5950
932	3113
933	4207
934	6594
935	3079
936	8060
937	6325
938	6100
939	8936
940	5807
941	0842
942	0780
943	5959
944	3912
945	7055
946	3348
947	6583
948	0762
949	8584
950	3044
951	6796
952	0753
953	2284
954	5455
955	6296
956	8347
957	4437
958	0227
959	0971
960	2528
961	8356
962	4432
963	8212
964	0726
965	2244
966	3351
967	6309
968	7935
969	0073
970	6937
971	7618
972	6915
973	5550
974	4272
975	8705
976	7311
977	7088
978	4003
979	7895
980	3852
981	7845
982	0131
983	9829
984	0101
985	2484
986	3600
987	5206
988	9580
989	7009
990	2911
991	1705
992	9007
993	9984
994	9963
995	4465
996	2051
997	5882
998	1176
999	5376
1000	6518
\.


--
-- Data for Name: account_info_trans_history; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.account_info_trans_history (trans_id, trans_time, trans_sourceid, trans_amount, trans_targetid, trans_reason, trans_method) FROM stdin;
\.


--
-- Data for Name: account_information; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.account_information (account_id, user_id, bank_id, bank_region, balance, opendate) FROM stdin;
1	1	16	south	4009.59	2024-05-19
2	2	7	north	477.14	2023-10-03
3	3	13	south	2391.57	2024-06-26
4	4	13	south	3775.57	2023-10-03
5	5	2	north	8740.33	2024-02-15
6	6	4	north	1050.50	2023-12-29
7	7	19	south	3175.20	2023-08-20
8	8	17	south	3763.44	2024-07-04
9	9	13	south	2542.41	2023-09-11
10	10	10	north	1088.83	2024-01-16
11	11	10	north	7355.53	2023-09-11
12	12	20	south	2904.54	2024-05-27
13	13	16	south	4955.90	2024-01-21
14	14	17	south	8764.91	2023-08-15
15	15	11	south	3806.57	2024-07-29
16	16	16	south	3094.98	2024-03-15
17	17	15	south	4648.09	2024-01-16
18	18	4	north	6927.04	2024-01-21
19	19	11	south	3511.18	2023-09-19
20	20	11	south	4978.43	2023-10-15
21	21	20	south	6403.88	2024-08-13
22	22	12	south	5902.90	2023-09-16
23	23	14	south	7698.44	2024-05-29
24	24	6	north	8027.99	2024-07-06
25	25	2	north	1906.25	2024-07-19
26	26	4	north	8534.02	2024-07-05
27	27	13	south	9127.38	2024-04-02
28	28	1	north	2050.85	2023-11-25
29	29	18	south	3737.12	2024-07-27
30	30	12	south	7280.88	2023-09-05
31	31	3	north	4854.31	2023-12-23
32	32	9	north	6981.46	2024-07-04
33	33	11	south	8883.35	2023-12-28
34	34	15	south	3890.17	2024-04-12
35	35	12	south	3798.00	2024-02-20
36	36	15	south	4319.15	2024-01-13
37	37	7	north	8214.50	2024-01-12
38	38	10	north	355.88	2023-09-27
39	39	3	north	4509.75	2024-06-01
40	40	5	north	1421.83	2023-12-30
41	41	1	north	7214.33	2023-11-01
42	42	3	north	1426.34	2024-06-22
43	43	14	south	1736.46	2023-09-08
44	44	16	south	4643.92	2024-03-14
45	45	13	south	9444.51	2023-12-26
46	46	2	north	9358.45	2024-03-26
47	47	4	north	7491.49	2024-07-24
48	48	16	south	8647.79	2023-10-02
49	49	19	south	8629.79	2024-04-02
50	50	15	south	3695.59	2023-10-23
51	51	1	north	9006.11	2024-06-02
52	52	18	south	8794.03	2024-07-05
53	53	16	south	8990.07	2024-03-03
54	54	13	south	7464.84	2024-02-12
55	55	4	north	3368.03	2023-11-09
56	56	13	south	6689.66	2023-12-28
57	57	7	north	3341.12	2023-12-04
58	58	14	south	8597.08	2024-05-30
59	59	18	south	632.97	2023-08-29
60	60	18	south	7860.77	2023-11-23
61	61	12	south	2592.47	2024-07-03
62	62	11	south	9956.86	2023-10-13
63	63	5	north	3133.10	2023-08-23
64	64	15	south	3850.75	2024-04-19
65	65	1	north	7842.70	2023-08-31
66	66	3	north	784.19	2023-11-30
67	67	14	south	953.95	2024-06-07
68	68	6	north	826.71	2024-04-19
69	69	16	south	9815.30	2024-06-30
70	70	12	south	4896.31	2023-11-04
71	71	7	north	4876.40	2024-02-16
72	72	11	south	4037.58	2024-05-27
73	73	14	south	2743.57	2023-09-20
74	74	12	south	5322.69	2024-04-16
75	75	3	north	6614.38	2023-10-09
76	76	6	north	8752.68	2024-04-23
77	77	17	south	6243.36	2023-12-04
78	78	11	south	7412.76	2023-12-14
79	79	1	north	7924.24	2024-06-13
80	80	16	south	317.38	2023-10-21
81	81	10	north	2079.57	2023-12-05
82	82	14	south	9947.66	2024-02-18
83	83	14	south	5980.14	2024-05-07
84	84	6	north	3301.30	2023-11-11
85	85	15	south	3285.19	2023-12-18
86	86	9	north	7128.67	2023-08-28
87	87	14	south	8788.01	2023-11-26
88	88	4	north	1225.32	2023-08-20
89	89	1	north	753.28	2024-03-21
90	90	7	north	7041.61	2024-05-23
91	91	6	north	2337.08	2024-02-28
92	92	17	south	3570.81	2023-10-02
93	93	3	north	8249.95	2024-04-05
94	94	18	south	4498.53	2024-08-11
95	95	12	south	2465.48	2024-06-21
96	96	7	north	9154.42	2023-12-21
97	97	17	south	2502.15	2024-08-05
98	98	20	south	3539.37	2023-12-30
99	99	17	south	5809.31	2023-09-27
100	100	14	south	3373.66	2023-08-30
101	101	2	north	99.88	2024-02-07
102	102	2	north	516.29	2024-03-06
103	103	9	north	4531.04	2024-03-12
104	104	1	north	8500.97	2024-05-27
105	105	5	north	9060.18	2024-06-20
106	106	18	south	891.61	2024-04-14
107	107	13	south	6380.10	2024-06-17
108	108	13	south	1084.85	2023-12-05
109	109	13	south	5614.54	2024-07-10
110	110	1	north	9110.73	2024-05-06
111	111	9	north	1212.57	2024-01-25
112	112	2	north	3910.60	2023-11-27
113	113	5	north	649.94	2024-03-13
114	114	7	north	167.61	2023-10-25
115	115	7	north	9700.73	2024-01-08
116	116	20	south	406.98	2024-04-18
117	117	19	south	1756.72	2024-02-23
118	118	16	south	3126.32	2024-06-16
119	119	10	north	5241.73	2023-09-18
120	120	7	north	6778.50	2024-05-04
121	121	4	north	9477.07	2024-04-28
122	122	13	south	3218.60	2023-09-06
123	123	9	north	7320.58	2024-03-26
124	124	20	south	1393.81	2023-10-07
125	125	20	south	3574.72	2024-07-07
126	126	5	north	7441.44	2024-02-26
127	127	19	south	9315.58	2023-09-06
128	128	12	south	8637.49	2023-12-30
129	129	8	north	9315.88	2024-05-01
130	130	16	south	1603.93	2024-08-07
131	131	9	north	2749.36	2024-07-14
132	132	18	south	9047.11	2023-11-22
133	133	4	north	2378.87	2023-09-11
134	134	20	south	5053.53	2024-07-05
135	135	19	south	2168.01	2024-07-15
136	136	11	south	6017.25	2024-07-15
137	137	14	south	1399.61	2023-09-10
138	138	18	south	9159.63	2024-03-16
139	139	18	south	2719.48	2024-06-01
140	140	12	south	6434.81	2023-11-08
141	141	13	south	2576.41	2023-12-04
142	142	15	south	808.60	2023-09-27
143	143	20	south	1936.21	2024-03-02
144	144	15	south	6349.11	2023-09-30
145	145	5	north	1271.59	2023-09-22
146	146	11	south	7656.72	2024-06-23
147	147	6	north	3586.73	2024-06-03
148	148	14	south	1567.09	2023-09-17
149	149	12	south	588.40	2024-05-25
150	150	19	south	6612.57	2024-05-11
151	151	8	north	3782.20	2023-11-12
152	152	17	south	7721.40	2023-12-22
153	153	3	north	3335.15	2024-08-14
154	154	2	north	757.51	2023-08-18
155	155	16	south	2619.31	2024-07-05
156	156	9	north	2725.07	2024-05-09
157	157	15	south	6041.56	2024-04-23
158	158	9	north	6891.55	2023-10-28
159	159	5	north	697.97	2023-11-01
160	160	4	north	8398.73	2024-03-28
161	161	8	north	3774.36	2023-12-05
162	162	14	south	6668.66	2024-06-13
163	163	10	north	4935.40	2024-07-23
164	164	1	north	7459.03	2023-10-11
165	165	14	south	2371.63	2024-06-04
166	166	16	south	6963.51	2024-01-21
167	167	2	north	5068.60	2024-04-03
168	168	11	south	512.42	2024-04-29
169	169	19	south	4125.97	2023-11-19
170	170	9	north	3126.83	2024-04-04
171	171	8	north	2022.31	2024-01-04
172	172	4	north	786.45	2024-07-01
173	173	18	south	890.73	2024-04-24
174	174	10	north	9520.97	2023-10-03
175	175	5	north	6201.55	2024-01-26
176	176	7	north	5264.42	2023-09-11
177	177	8	north	6003.04	2024-04-04
178	178	17	south	114.29	2023-11-21
179	179	13	south	3057.05	2023-11-13
180	180	14	south	3334.85	2024-03-26
181	181	5	north	6942.41	2024-07-07
182	182	4	north	6255.97	2024-01-29
183	183	19	south	708.01	2024-05-29
184	184	7	north	7166.35	2024-08-14
185	185	19	south	2969.47	2024-03-19
186	186	4	north	5491.54	2024-05-05
187	187	13	south	9410.13	2024-03-22
188	188	9	north	6888.48	2024-05-24
189	189	14	south	9396.02	2023-10-01
190	190	1	north	4702.27	2023-11-06
191	191	5	north	7680.61	2024-05-25
192	192	20	south	7470.38	2024-08-05
193	193	2	north	4614.87	2024-05-30
194	194	6	north	6249.35	2024-02-29
195	195	8	north	3066.41	2023-10-20
196	196	15	south	8250.37	2023-10-19
197	197	10	north	8405.37	2023-10-30
198	198	7	north	8827.29	2024-01-22
199	199	17	south	4044.65	2023-12-05
200	200	19	south	6787.47	2024-01-26
201	201	15	south	827.39	2024-05-09
202	202	16	south	7636.04	2023-08-31
203	203	3	north	7304.20	2024-06-26
204	204	8	north	1913.00	2024-01-21
205	205	20	south	999.71	2024-05-24
206	206	10	north	6707.24	2023-08-15
207	207	12	south	8570.57	2024-06-02
208	208	17	south	7202.49	2024-05-27
209	209	4	north	3425.19	2023-12-20
210	210	3	north	573.59	2023-12-30
211	211	20	south	3061.01	2023-09-11
212	212	17	south	6981.63	2024-08-11
213	213	10	north	3440.66	2023-08-28
214	214	9	north	7252.15	2024-03-02
215	215	1	north	7409.09	2024-01-20
216	216	6	north	2481.81	2024-05-21
217	217	19	south	2186.81	2023-11-03
218	218	7	north	4738.39	2023-12-25
219	219	15	south	4993.39	2023-12-29
220	220	20	south	8911.31	2023-09-17
221	221	10	north	4299.57	2024-06-02
222	222	13	south	2455.09	2024-08-01
223	223	17	south	3383.58	2024-03-09
224	224	7	north	8297.18	2024-07-22
225	225	13	south	8079.61	2023-08-18
226	226	16	south	9649.50	2024-05-19
227	227	19	south	8783.78	2023-12-20
228	228	10	north	3604.38	2024-06-22
229	229	8	north	5501.34	2024-01-24
230	230	16	south	3662.02	2024-06-04
231	231	4	north	7050.36	2023-12-12
232	232	19	south	7796.55	2024-03-27
233	233	9	north	2921.95	2023-10-21
234	234	7	north	3695.70	2024-02-25
235	235	6	north	5858.67	2023-12-28
236	236	16	south	849.16	2023-11-01
237	237	1	north	2812.53	2023-11-02
238	238	2	north	7436.91	2023-10-27
239	239	17	south	5071.12	2024-08-07
240	240	2	north	2920.46	2024-03-25
241	241	15	south	5324.36	2024-02-06
242	242	13	south	3734.89	2024-03-08
243	243	7	north	901.18	2024-02-11
244	244	18	south	4286.60	2023-10-30
245	245	14	south	4444.81	2024-06-20
246	246	14	south	3886.06	2023-12-04
247	247	16	south	3743.47	2024-04-26
248	248	3	north	2439.20	2024-04-25
249	249	15	south	8289.02	2023-09-16
250	250	5	north	7051.59	2023-10-08
251	251	7	north	4647.81	2024-06-15
252	252	17	south	5694.86	2024-04-11
253	253	1	north	1259.11	2023-11-18
254	254	14	south	3804.84	2023-12-17
255	255	2	north	464.36	2024-02-03
256	256	13	south	892.90	2024-06-15
257	257	11	south	8445.63	2023-08-21
258	258	5	north	8180.86	2024-07-26
259	259	7	north	5912.76	2024-01-10
260	260	12	south	1311.03	2024-03-10
261	261	17	south	8783.50	2023-12-31
262	262	1	north	8254.99	2024-07-05
263	263	4	north	372.82	2024-07-16
264	264	12	south	3580.07	2024-04-03
265	265	1	north	218.95	2024-04-29
266	266	6	north	4161.75	2023-10-11
267	267	17	south	7253.66	2023-11-29
268	268	20	south	5307.49	2024-02-12
269	269	11	south	1240.26	2023-08-18
270	270	15	south	3143.01	2024-02-04
271	271	13	south	453.20	2023-09-05
272	272	19	south	3435.42	2023-09-09
273	273	5	north	8103.75	2023-12-09
274	274	13	south	1037.52	2023-08-19
275	275	8	north	2386.65	2023-12-11
276	276	12	south	7902.78	2024-07-19
277	277	5	north	8250.69	2024-02-28
278	278	4	north	9611.03	2024-06-12
279	279	3	north	3407.01	2024-04-13
280	280	5	north	8158.20	2023-12-21
281	281	12	south	2453.08	2023-09-04
282	282	15	south	4789.13	2024-03-25
283	283	3	north	4520.12	2024-06-22
284	284	19	south	2109.67	2023-09-09
285	285	16	south	7348.18	2023-10-13
286	286	19	south	9334.34	2023-09-09
287	287	15	south	1556.20	2024-07-09
288	288	9	north	6823.03	2023-09-24
289	289	10	north	9742.74	2023-11-27
290	290	17	south	1050.59	2023-11-13
291	291	20	south	2958.86	2024-02-16
292	292	14	south	3108.09	2023-11-04
293	293	6	north	3205.65	2023-11-04
294	294	19	south	180.47	2024-06-14
295	295	16	south	2358.86	2024-05-29
296	296	1	north	4268.85	2024-04-03
297	297	6	north	1722.03	2023-11-11
298	298	17	south	8880.30	2023-09-24
299	299	2	north	7819.90	2023-09-13
300	300	14	south	115.17	2023-12-22
301	301	20	south	9905.55	2023-11-26
302	302	9	north	1197.46	2024-04-24
303	303	9	north	7762.65	2024-01-15
304	304	5	north	4274.13	2023-11-30
305	305	18	south	7446.08	2024-07-28
306	306	18	south	6888.46	2023-11-14
307	307	7	north	6521.43	2024-04-17
308	308	6	north	3744.11	2023-09-30
309	309	12	south	7524.86	2023-11-11
310	310	16	south	9501.34	2023-08-16
311	311	16	south	7926.63	2023-09-24
312	312	8	north	2864.81	2023-08-18
313	313	1	north	5562.04	2024-08-09
314	314	13	south	979.78	2023-09-17
315	315	15	south	2435.79	2023-08-21
316	316	14	south	8834.90	2024-06-08
317	317	10	north	6847.02	2024-04-06
318	318	5	north	5861.77	2023-12-22
319	319	9	north	9311.40	2024-02-13
320	320	16	south	7632.88	2023-09-04
321	321	13	south	2095.44	2023-11-03
322	322	4	north	753.22	2023-12-18
323	323	18	south	2987.48	2024-06-11
324	324	11	south	8913.93	2024-07-01
325	325	10	north	1838.03	2024-06-20
326	326	9	north	8557.74	2024-06-20
327	327	18	south	664.45	2024-02-21
328	328	7	north	3147.61	2024-07-21
329	329	12	south	3409.77	2023-12-26
330	330	17	south	6209.12	2024-04-20
331	331	15	south	4678.86	2024-03-12
332	332	20	south	2739.55	2024-04-01
333	333	17	south	6803.30	2024-05-20
334	334	6	north	696.14	2023-10-25
335	335	9	north	7587.78	2024-03-19
336	336	9	north	8663.34	2024-01-22
337	337	7	north	3805.21	2024-08-02
338	338	16	south	305.96	2024-07-01
339	339	6	north	725.05	2023-11-01
340	340	14	south	7077.20	2024-08-06
341	341	4	north	6042.47	2024-05-11
342	342	16	south	6113.42	2024-05-12
343	343	10	north	9361.70	2023-09-03
344	344	18	south	8786.22	2023-12-04
345	345	17	south	7439.52	2024-06-11
346	346	20	south	243.77	2024-01-06
347	347	1	north	3550.06	2023-09-17
348	348	6	north	186.08	2024-03-23
349	349	3	north	6704.90	2024-01-21
350	350	12	south	4352.68	2023-12-23
351	351	13	south	2159.54	2024-05-21
352	352	2	north	770.59	2023-11-27
353	353	20	south	5297.67	2024-05-25
354	354	17	south	8675.45	2023-09-22
355	355	3	north	5461.11	2024-04-15
356	356	13	south	8859.50	2024-01-07
357	357	19	south	9983.26	2023-11-03
358	358	9	north	3208.56	2023-10-18
359	359	20	south	2247.02	2024-03-31
360	360	3	north	2047.64	2024-03-21
361	361	7	north	4661.57	2023-11-22
362	362	15	south	3546.11	2023-12-18
363	363	7	north	6794.86	2024-04-02
364	364	13	south	8150.99	2023-09-18
365	365	14	south	6532.92	2024-06-22
366	366	17	south	5441.95	2024-03-26
367	367	19	south	3114.48	2024-07-30
368	368	7	north	6426.04	2024-04-30
369	369	9	north	3056.20	2024-07-25
370	370	19	south	984.84	2024-07-13
371	371	3	north	1895.18	2024-07-16
372	372	16	south	3749.72	2024-04-20
373	373	5	north	1587.50	2023-11-03
374	374	13	south	9576.63	2023-12-03
375	375	19	south	4132.01	2024-07-26
376	376	19	south	7985.92	2023-12-25
377	377	5	north	5561.82	2023-08-28
378	378	1	north	2645.17	2024-01-28
379	379	1	north	9903.55	2024-02-05
380	380	14	south	424.85	2024-02-09
381	381	15	south	2360.45	2024-03-18
382	382	14	south	7380.19	2024-02-27
383	383	11	south	741.45	2023-09-22
384	384	8	north	2607.81	2023-09-17
385	385	15	south	6950.86	2024-01-17
386	386	1	north	7257.60	2024-08-05
387	387	20	south	9304.50	2023-10-13
388	388	3	north	4729.22	2023-12-14
389	389	12	south	4213.49	2023-09-08
390	390	7	north	1157.84	2023-10-11
391	391	12	south	8808.16	2024-04-08
392	392	1	north	7249.24	2023-11-29
393	393	10	north	778.87	2024-07-10
394	394	4	north	5356.54	2024-07-21
395	395	3	north	1073.05	2023-10-27
396	396	18	south	1981.61	2024-03-11
397	397	7	north	7224.68	2024-03-13
398	398	2	north	7808.11	2024-08-12
399	399	4	north	6409.90	2023-10-09
400	400	11	south	1667.68	2024-02-11
401	401	19	south	4726.23	2024-06-18
402	402	16	south	9593.06	2024-04-15
403	403	18	south	5303.70	2023-11-16
404	404	9	north	7080.35	2024-05-09
405	405	7	north	6368.58	2023-10-16
406	406	4	north	1641.41	2023-09-29
407	407	18	south	8212.52	2023-09-16
408	408	10	north	5792.02	2024-04-03
409	409	10	north	7903.76	2024-07-21
410	410	6	north	7338.80	2024-05-07
411	411	5	north	7220.52	2024-01-02
412	412	12	south	6850.64	2023-08-23
413	413	19	south	8686.47	2024-05-17
414	414	15	south	692.44	2024-04-27
415	415	1	north	5501.95	2024-05-09
416	416	4	north	3885.68	2024-04-20
417	417	1	north	5031.39	2023-12-03
418	418	10	north	649.44	2024-03-20
419	419	1	north	638.02	2024-06-28
420	420	3	north	9943.17	2024-05-05
421	421	4	north	5557.42	2024-01-13
422	422	4	north	7631.04	2024-08-07
423	423	9	north	7101.14	2023-09-09
424	424	5	north	3722.87	2024-07-15
425	425	19	south	8338.55	2024-03-30
426	426	16	south	5324.24	2024-01-26
427	427	17	south	6400.24	2024-02-16
428	428	14	south	6535.14	2024-01-20
429	429	5	north	8845.09	2023-09-28
430	430	6	north	9185.04	2024-06-10
431	431	2	north	4576.77	2023-11-03
432	432	11	south	8590.09	2024-07-10
433	433	15	south	5667.09	2024-03-26
434	434	13	south	1487.84	2024-06-29
435	435	19	south	4201.71	2024-07-01
436	436	5	north	6255.14	2024-04-20
437	437	2	north	9204.00	2023-08-29
438	438	20	south	3853.09	2024-08-03
439	439	6	north	6651.62	2024-02-20
440	440	8	north	9744.48	2023-12-22
441	441	2	north	7231.96	2024-04-18
442	442	6	north	5542.76	2023-08-16
443	443	7	north	909.43	2023-12-13
444	444	5	north	3850.69	2023-12-25
445	445	6	north	8647.07	2024-02-19
446	446	2	north	5965.30	2024-03-09
447	447	11	south	4779.12	2023-08-20
448	448	9	north	8654.63	2024-03-20
449	449	3	north	3448.14	2024-07-24
450	450	11	south	8877.25	2023-11-07
451	451	11	south	1624.42	2023-11-12
452	452	5	north	7132.79	2024-03-08
453	453	18	south	3925.75	2024-07-05
454	454	5	north	377.83	2024-04-19
455	455	3	north	6748.50	2023-11-20
456	456	4	north	2893.84	2024-01-29
457	457	2	north	9727.40	2024-07-09
458	458	9	north	6395.01	2024-04-29
459	459	17	south	7419.07	2023-12-31
460	460	17	south	8655.96	2023-08-17
461	461	20	south	7846.74	2024-03-11
462	462	18	south	6783.46	2024-02-29
463	463	5	north	6243.52	2024-08-04
464	464	5	north	520.92	2024-06-10
465	465	4	north	3163.44	2023-08-29
466	466	18	south	5061.90	2023-09-26
467	467	12	south	5835.54	2024-08-09
468	468	7	north	8903.06	2024-08-13
469	469	6	north	6193.75	2024-02-09
470	470	9	north	8851.01	2024-04-10
471	471	5	north	7547.09	2024-07-29
472	472	15	south	204.92	2023-09-23
473	473	4	north	2182.79	2024-04-24
474	474	18	south	911.26	2024-05-25
475	475	19	south	6997.46	2024-03-04
476	476	15	south	7506.41	2024-07-19
477	477	10	north	3032.36	2023-12-31
478	478	7	north	7927.00	2024-01-11
479	479	20	south	5321.26	2024-07-13
480	480	2	north	6343.85	2023-12-12
481	481	5	north	9524.80	2024-03-10
482	482	2	north	6521.23	2024-02-23
483	483	18	south	7980.34	2024-08-11
484	484	4	north	9041.76	2023-10-09
485	485	7	north	2752.39	2024-07-13
486	486	10	north	8226.64	2024-06-15
487	487	20	south	1409.80	2024-06-02
488	488	19	south	1685.27	2024-08-13
489	489	3	north	7091.50	2023-11-01
490	490	15	south	4248.33	2023-12-11
491	491	5	north	628.87	2024-03-23
492	492	9	north	3807.31	2024-03-24
493	493	11	south	293.22	2024-06-03
494	494	2	north	5142.78	2024-04-17
495	495	7	north	4588.14	2023-11-18
496	496	5	north	3415.15	2024-05-03
497	497	13	south	5368.26	2023-10-23
498	498	6	north	6870.21	2024-01-28
499	499	4	north	571.53	2023-12-10
500	500	14	south	97.32	2024-06-15
501	501	7	north	4801.70	2024-03-12
502	502	10	north	478.20	2024-01-26
503	503	1	north	6141.94	2024-06-20
504	504	19	south	1257.07	2023-11-03
505	505	18	south	8275.50	2024-07-12
506	506	5	north	2582.02	2024-07-05
507	507	10	north	3114.69	2023-10-03
508	508	12	south	5107.99	2024-02-15
509	509	6	north	3579.56	2023-11-28
510	510	6	north	2996.03	2023-10-09
511	511	12	south	3563.72	2024-05-17
512	512	3	north	3738.13	2023-12-05
513	513	20	south	7022.69	2024-04-10
514	514	14	south	4116.96	2024-02-25
515	515	8	north	4692.98	2023-12-06
516	516	11	south	7334.86	2024-04-05
517	517	20	south	3764.43	2024-01-02
518	518	5	north	5801.01	2023-11-23
519	519	15	south	1486.02	2024-03-17
520	520	12	south	8131.64	2024-05-16
521	521	12	south	1132.05	2023-12-28
522	522	9	north	7177.55	2024-06-25
523	523	14	south	1988.79	2024-07-28
524	524	10	north	8618.43	2023-11-04
525	525	5	north	9421.82	2024-01-09
526	526	6	north	2040.23	2024-03-15
527	527	17	south	8880.82	2023-10-14
528	528	1	north	8446.61	2023-10-10
529	529	20	south	8606.43	2024-05-31
530	530	16	south	2287.67	2023-09-02
531	531	15	south	6894.75	2023-11-05
532	532	16	south	4932.11	2024-03-06
533	533	18	south	5741.08	2023-10-21
534	534	17	south	3177.47	2024-03-18
535	535	4	north	1344.80	2024-07-14
536	536	16	south	2286.44	2023-11-25
537	537	3	north	8027.52	2024-05-25
538	538	13	south	459.78	2024-04-22
539	539	17	south	398.63	2023-09-18
540	540	8	north	3111.99	2023-11-25
541	541	13	south	2501.37	2024-03-03
542	542	14	south	7352.82	2024-01-18
543	543	13	south	5967.39	2024-07-15
544	544	12	south	6116.70	2024-02-18
545	545	13	south	1765.32	2024-08-06
546	546	4	north	3844.26	2024-05-10
547	547	14	south	7998.28	2024-04-26
548	548	14	south	6122.83	2024-05-17
549	549	5	north	6626.19	2024-03-15
550	550	3	north	1702.25	2024-02-09
551	551	4	north	5166.96	2024-02-04
552	552	3	north	634.73	2024-01-19
553	553	7	north	7254.54	2024-07-11
554	554	12	south	6900.96	2024-04-20
555	555	5	north	7285.99	2024-05-02
556	556	9	north	1934.65	2024-02-24
557	557	5	north	861.73	2023-11-24
558	558	15	south	3256.84	2023-09-19
559	559	16	south	2689.59	2023-12-09
560	560	9	north	3027.64	2023-11-29
561	561	19	south	4725.59	2023-09-07
562	562	8	north	8975.92	2024-07-28
563	563	13	south	7263.06	2024-07-05
564	564	12	south	2467.89	2023-12-09
565	565	3	north	1309.27	2023-09-05
566	566	14	south	6974.02	2024-08-03
567	567	15	south	3192.10	2024-03-21
568	568	9	north	481.41	2023-12-19
569	569	2	north	2772.25	2023-10-01
570	570	9	north	4807.45	2024-05-17
571	571	10	north	1277.95	2023-12-25
572	572	5	north	4849.25	2023-12-06
573	573	8	north	1806.28	2024-07-31
574	574	15	south	1260.62	2024-06-07
575	575	4	north	555.84	2023-08-15
576	576	12	south	4564.73	2024-06-23
577	577	18	south	3584.74	2023-10-08
578	578	16	south	344.41	2024-02-26
579	579	20	south	724.68	2024-05-09
580	580	17	south	8721.75	2024-01-20
581	581	15	south	7659.40	2024-05-22
582	582	18	south	8050.72	2024-02-28
583	583	9	north	6979.69	2024-06-26
584	584	19	south	4900.23	2023-09-18
585	585	5	north	8952.44	2024-03-18
586	586	17	south	6676.89	2023-10-26
587	587	20	south	9484.40	2023-10-25
588	588	3	north	3000.46	2023-11-17
589	589	20	south	3016.90	2023-11-16
590	590	8	north	3955.53	2023-12-26
591	591	16	south	9352.91	2024-07-11
592	592	10	north	9049.88	2023-10-02
593	593	12	south	4849.40	2023-09-19
594	594	9	north	1596.26	2023-10-12
595	595	19	south	6096.54	2024-07-13
596	596	15	south	9231.19	2024-05-18
597	597	15	south	8935.16	2024-02-03
598	598	3	north	7287.71	2024-02-29
599	599	16	south	3360.84	2023-12-14
600	600	1	north	1759.99	2024-07-27
601	601	20	south	5553.08	2024-03-11
602	602	16	south	1011.43	2024-07-06
603	603	16	south	6393.98	2024-04-18
604	604	4	north	1898.94	2024-01-21
605	605	2	north	8057.54	2024-01-13
606	606	19	south	5722.21	2024-05-05
607	607	15	south	4704.58	2024-05-23
608	608	14	south	6143.46	2024-01-18
609	609	4	north	4825.03	2024-02-20
610	610	12	south	1936.35	2024-02-28
611	611	16	south	4110.26	2023-09-20
612	612	9	north	4446.24	2024-06-09
613	613	2	north	6356.73	2024-04-10
614	614	17	south	6180.24	2024-02-17
615	615	4	north	4638.66	2024-06-24
616	616	4	north	5224.34	2024-01-17
617	617	1	north	4229.14	2023-09-20
618	618	9	north	9792.57	2024-03-06
619	619	10	north	6661.80	2024-03-10
620	620	20	south	2247.77	2023-10-15
621	621	19	south	9318.12	2024-07-29
622	622	4	north	6409.25	2023-12-18
623	623	15	south	4523.41	2023-12-14
624	624	6	north	1941.78	2024-08-07
625	625	18	south	912.06	2024-05-31
626	626	19	south	2217.52	2024-01-28
627	627	13	south	1579.61	2023-09-01
628	628	5	north	7437.33	2023-08-16
629	629	20	south	1605.57	2024-07-13
630	630	4	north	1722.51	2024-03-08
631	631	9	north	8325.04	2023-08-26
632	632	3	north	1348.07	2023-11-24
633	633	7	north	2069.21	2024-03-10
634	634	5	north	1454.81	2024-02-03
635	635	14	south	8625.71	2023-10-02
636	636	9	north	2038.08	2023-12-02
637	637	6	north	2690.70	2023-12-25
638	638	11	south	3613.06	2023-08-22
639	639	10	north	5809.71	2024-02-06
640	640	2	north	982.15	2023-08-22
641	641	17	south	436.74	2023-12-04
642	642	2	north	3959.02	2024-04-23
643	643	3	north	1788.28	2023-11-19
644	644	18	south	947.31	2024-02-09
645	645	15	south	6784.49	2024-05-15
646	646	3	north	1316.08	2023-10-31
647	647	13	south	4169.54	2024-05-08
648	648	20	south	303.00	2024-06-29
649	649	16	south	7294.12	2023-11-17
650	650	10	north	1009.88	2024-03-23
651	651	5	north	1056.08	2023-11-23
652	652	2	north	1422.50	2024-01-14
653	653	8	north	8212.40	2024-05-02
654	654	10	north	4567.67	2024-04-16
655	655	3	north	9895.88	2023-08-27
656	656	15	south	775.30	2023-09-09
657	657	10	north	1958.05	2024-08-04
658	658	14	south	5251.62	2024-08-08
659	659	20	south	6624.72	2023-10-21
660	660	15	south	607.67	2023-12-11
661	661	20	south	8785.47	2024-07-29
662	662	3	north	6432.08	2023-09-21
663	663	5	north	433.30	2024-06-05
664	664	1	north	8441.89	2024-05-11
665	665	8	north	2618.97	2024-07-17
666	666	5	north	3883.68	2023-09-07
667	667	20	south	1370.85	2024-05-17
668	668	14	south	9376.13	2024-04-02
669	669	11	south	9755.80	2023-10-28
670	670	10	north	9021.55	2024-03-01
671	671	18	south	8477.03	2024-04-04
672	672	4	north	4924.07	2024-01-20
673	673	4	north	2833.04	2023-12-18
674	674	8	north	2673.49	2024-03-05
675	675	7	north	1537.09	2024-04-13
676	676	2	north	7613.79	2024-03-16
677	677	16	south	4270.85	2024-06-01
678	678	14	south	236.56	2023-09-06
679	679	4	north	9263.47	2024-03-22
680	680	6	north	9009.09	2024-02-20
681	681	6	north	8220.98	2023-11-09
682	682	9	north	1249.57	2023-12-22
683	683	14	south	1638.67	2023-11-22
684	684	5	north	1157.33	2024-04-10
685	685	2	north	5829.06	2023-08-29
686	686	12	south	4818.75	2023-09-26
687	687	5	north	2482.69	2024-03-30
688	688	6	north	8933.53	2024-05-29
689	689	20	south	5309.70	2023-09-13
690	690	16	south	9590.09	2024-03-19
691	691	13	south	9270.26	2024-06-20
692	692	10	north	9433.85	2024-02-06
693	693	1	north	9593.68	2024-03-28
694	694	12	south	9326.21	2024-03-31
695	695	10	north	6576.79	2024-05-20
696	696	14	south	6713.88	2023-11-25
697	697	20	south	1346.03	2024-04-14
698	698	7	north	7831.89	2023-12-04
699	699	16	south	9793.88	2023-10-18
700	700	1	north	8924.24	2024-04-12
701	701	7	north	2876.64	2023-12-25
702	702	11	south	3981.25	2023-12-12
703	703	14	south	6229.35	2024-02-23
704	704	8	north	806.49	2023-09-24
705	705	19	south	1575.17	2023-09-18
706	706	20	south	614.90	2024-06-19
707	707	12	south	7716.57	2024-04-21
708	708	20	south	7131.62	2023-10-24
709	709	17	south	7623.78	2024-08-09
710	710	18	south	3084.83	2024-02-25
711	711	8	north	6491.59	2024-08-09
712	712	7	north	8638.28	2023-12-30
713	713	13	south	1397.77	2024-02-13
714	714	14	south	1194.25	2024-06-20
715	715	14	south	4089.31	2024-08-12
716	716	13	south	2448.01	2024-02-04
717	717	1	north	2186.81	2024-01-18
718	718	8	north	1033.61	2023-10-23
719	719	2	north	8130.60	2024-03-14
720	720	6	north	1371.93	2024-05-29
721	721	8	north	8139.63	2023-09-30
722	722	9	north	3827.17	2024-08-13
723	723	5	north	1948.53	2024-03-06
724	724	9	north	3284.10	2024-04-12
725	725	11	south	6371.93	2024-02-23
726	726	7	north	8976.07	2024-04-18
727	727	15	south	589.55	2024-06-20
728	728	3	north	3302.32	2024-01-12
729	729	5	north	7269.28	2024-05-02
730	730	5	north	3106.13	2024-01-30
731	731	14	south	6382.90	2023-10-31
732	732	10	north	438.73	2024-07-02
733	733	3	north	4865.04	2024-05-20
734	734	9	north	196.45	2024-05-01
735	735	14	south	8652.43	2023-12-23
736	736	20	south	3377.71	2023-08-30
737	737	1	north	1393.56	2024-04-16
738	738	6	north	1290.39	2024-06-18
739	739	20	south	297.53	2023-11-15
740	740	12	south	5391.84	2024-03-31
741	741	17	south	795.02	2023-10-18
742	742	15	south	6152.14	2024-07-09
743	743	6	north	5569.94	2024-04-06
744	744	7	north	7674.54	2024-07-08
745	745	12	south	5789.17	2024-03-17
746	746	20	south	5011.98	2023-09-07
747	747	18	south	1926.54	2024-04-17
748	748	18	south	7391.52	2024-05-27
749	749	4	north	3329.93	2024-04-26
750	750	13	south	6998.51	2024-04-03
751	751	7	north	622.74	2023-10-14
752	752	7	north	6006.94	2024-04-16
753	753	4	north	9677.25	2024-04-03
754	754	8	north	4677.32	2024-04-23
755	755	11	south	5700.57	2024-04-11
756	756	11	south	7716.12	2024-07-24
757	757	12	south	9848.87	2023-10-30
758	758	3	north	5930.09	2024-06-21
759	759	1	north	9224.53	2024-05-01
760	760	17	south	9249.16	2024-08-04
761	761	16	south	7048.68	2023-12-03
762	762	2	north	9723.41	2023-10-15
763	763	9	north	3334.28	2024-02-23
764	764	9	north	6527.57	2023-08-17
765	765	11	south	3127.76	2024-01-23
766	766	18	south	476.81	2024-02-13
767	767	2	north	8377.44	2023-12-26
768	768	16	south	4498.04	2023-11-26
769	769	4	north	9770.45	2024-02-21
770	770	6	north	6803.09	2023-11-30
771	771	15	south	1485.18	2023-12-09
772	772	7	north	5343.70	2023-11-15
773	773	17	south	7537.72	2024-07-19
774	774	5	north	715.29	2024-05-27
775	775	11	south	8375.29	2024-04-02
776	776	8	north	928.07	2023-11-26
777	777	11	south	3875.06	2024-03-10
778	778	20	south	5443.92	2024-03-01
779	779	11	south	2088.76	2023-12-28
780	780	12	south	4770.34	2023-12-19
781	781	10	north	4535.77	2023-11-20
782	782	10	north	2620.37	2024-05-03
783	783	4	north	2596.02	2024-03-30
784	784	17	south	6363.18	2023-09-24
785	785	1	north	7352.43	2023-10-05
786	786	2	north	540.81	2024-07-13
787	787	13	south	8831.96	2024-01-11
788	788	3	north	1150.91	2024-04-16
789	789	1	north	4286.51	2024-01-14
790	790	9	north	3326.87	2024-01-02
791	791	5	north	9116.05	2024-05-09
792	792	13	south	2864.09	2024-03-19
793	793	13	south	5462.64	2024-03-28
794	794	4	north	3840.02	2024-05-30
795	795	3	north	9051.25	2024-07-28
796	796	16	south	1423.40	2023-08-31
797	797	1	north	2499.28	2024-01-19
798	798	15	south	7053.52	2023-09-25
799	799	5	north	2848.75	2023-12-07
800	800	10	north	3969.21	2023-08-19
801	801	5	north	4709.41	2024-04-07
802	802	10	north	2049.08	2024-06-16
803	803	9	north	8999.97	2023-11-20
804	804	1	north	8224.62	2024-04-07
805	805	2	north	2766.95	2024-06-09
806	806	10	north	6458.38	2024-03-23
807	807	11	south	3220.23	2024-04-24
808	808	5	north	1038.69	2024-07-27
809	809	5	north	6926.38	2024-05-28
810	810	18	south	6382.99	2024-04-16
811	811	14	south	1101.90	2024-01-06
812	812	17	south	2582.81	2024-04-05
813	813	6	north	6787.57	2024-07-09
814	814	19	south	120.15	2023-09-25
815	815	12	south	6896.05	2023-11-17
816	816	6	north	4342.16	2023-10-28
817	817	1	north	872.43	2024-03-30
818	818	18	south	3471.96	2023-09-13
819	819	6	north	7176.08	2024-06-11
820	820	11	south	214.86	2024-03-02
821	821	6	north	5353.73	2024-07-23
822	822	15	south	6245.51	2024-04-28
823	823	6	north	1401.49	2023-11-27
824	824	5	north	5855.97	2023-09-14
825	825	18	south	8625.66	2024-07-27
826	826	4	north	4578.90	2024-07-31
827	827	5	north	9180.23	2024-08-09
828	828	17	south	2569.12	2024-03-08
829	829	15	south	9222.01	2024-05-02
830	830	15	south	2608.18	2023-08-18
831	831	17	south	4871.99	2024-01-21
832	832	12	south	100.93	2024-07-20
833	833	7	north	6470.65	2024-07-17
834	834	19	south	9996.08	2024-07-24
835	835	10	north	4899.86	2024-01-22
836	836	19	south	7039.33	2024-03-22
837	837	6	north	8141.14	2023-12-14
838	838	20	south	9717.27	2024-02-08
839	839	6	north	7299.21	2024-06-27
840	840	20	south	1338.26	2024-07-10
841	841	13	south	6660.74	2024-04-23
842	842	16	south	5156.92	2023-10-24
843	843	20	south	1450.71	2024-01-29
844	844	14	south	3379.08	2023-09-28
845	845	9	north	1707.82	2023-10-19
846	846	20	south	3501.89	2024-03-23
847	847	10	north	6203.53	2023-09-28
848	848	3	north	8867.07	2023-11-18
849	849	17	south	2303.11	2024-04-09
850	850	9	north	7826.31	2023-10-04
851	851	9	north	2438.83	2023-12-10
852	852	15	south	723.00	2024-03-17
853	853	11	south	2661.22	2023-09-29
854	854	1	north	615.20	2024-01-27
855	855	9	north	4375.04	2023-10-17
856	856	1	north	8775.65	2024-04-20
857	857	10	north	6094.12	2024-04-13
858	858	3	north	6705.80	2024-08-06
859	859	3	north	8362.32	2023-09-11
860	860	7	north	4176.95	2024-04-02
861	861	1	north	816.80	2024-08-05
862	862	9	north	4385.24	2024-06-25
863	863	19	south	7091.03	2023-09-18
864	864	4	north	2565.89	2024-02-23
865	865	6	north	2533.65	2024-06-11
866	866	15	south	4831.29	2024-07-11
867	867	12	south	2479.48	2023-10-04
868	868	9	north	272.65	2024-05-23
869	869	9	north	5126.97	2023-12-15
870	870	12	south	6448.86	2024-06-01
871	871	13	south	910.04	2024-04-27
872	872	20	south	3916.40	2024-05-11
873	873	16	south	6688.80	2023-09-02
874	874	1	north	1275.81	2024-01-15
875	875	19	south	4564.77	2023-10-02
876	876	2	north	4039.81	2024-06-15
877	877	4	north	7895.43	2024-07-10
878	878	20	south	7557.45	2023-09-29
879	879	19	south	7775.11	2023-10-19
880	880	20	south	5536.98	2024-07-23
881	881	14	south	2245.43	2023-09-06
882	882	7	north	4515.66	2024-04-27
883	883	20	south	9766.72	2024-08-08
884	884	2	north	6833.31	2024-06-09
885	885	3	north	7992.07	2023-11-11
886	886	11	south	9128.63	2023-09-26
887	887	13	south	8811.72	2023-11-17
888	888	15	south	9430.00	2023-12-13
889	889	10	north	3682.69	2024-02-10
890	890	2	north	851.65	2023-12-31
891	891	17	south	7524.18	2024-07-26
892	892	18	south	1352.22	2024-07-19
893	893	4	north	4429.22	2023-09-14
894	894	14	south	9683.29	2024-05-27
895	895	6	north	1573.74	2023-11-06
896	896	16	south	6470.35	2023-10-04
897	897	8	north	8777.67	2023-12-29
898	898	1	north	8239.16	2024-04-02
899	899	16	south	2760.26	2024-06-04
900	900	20	south	6868.91	2024-02-05
901	901	20	south	814.99	2024-08-08
902	902	20	south	5452.03	2023-12-27
903	903	11	south	682.13	2024-03-23
904	904	6	north	5564.93	2024-05-22
905	905	7	north	7404.73	2024-03-12
906	906	10	north	3186.03	2023-11-27
907	907	19	south	6918.05	2023-11-07
908	908	12	south	3603.70	2023-12-28
909	909	13	south	4763.53	2024-06-28
910	910	12	south	2811.91	2024-07-15
911	911	7	north	2841.59	2023-08-22
912	912	2	north	8441.36	2024-04-11
913	913	7	north	4145.16	2024-08-11
914	914	19	south	621.40	2024-03-21
915	915	8	north	4597.89	2024-05-26
916	916	2	north	2204.90	2024-01-26
917	917	5	north	2140.45	2024-03-22
918	918	13	south	6922.37	2023-10-23
919	919	2	north	5707.33	2024-05-15
920	920	6	north	1851.83	2024-08-11
921	921	12	south	7333.69	2024-07-23
922	922	17	south	9118.28	2023-09-14
923	923	1	north	9455.81	2023-09-30
924	924	19	south	2485.35	2024-02-05
925	925	16	south	8886.68	2024-08-07
926	926	16	south	6621.21	2023-11-04
927	927	9	north	2336.74	2024-05-03
928	928	9	north	7557.53	2023-12-16
929	929	4	north	3513.29	2024-07-17
930	930	10	north	3902.66	2024-07-11
931	931	14	south	7834.33	2024-02-16
932	932	12	south	2749.43	2024-04-01
933	933	14	south	3330.99	2023-12-19
934	934	12	south	2726.23	2023-08-20
935	935	1	north	4421.91	2023-12-13
936	936	15	south	8299.91	2023-09-09
937	937	12	south	451.57	2024-02-10
938	938	9	north	7191.70	2023-11-17
939	939	1	north	6632.30	2024-01-14
940	940	17	south	5084.24	2024-06-29
941	941	11	south	6160.41	2024-05-19
942	942	8	north	9523.21	2024-04-24
943	943	7	north	871.78	2023-09-22
944	944	14	south	7448.77	2024-02-10
945	945	5	north	4508.66	2023-10-02
946	946	13	south	8539.75	2023-09-26
947	947	8	north	3034.75	2024-06-24
948	948	20	south	8589.76	2024-04-15
949	949	11	south	1952.88	2023-11-10
950	950	17	south	54.62	2024-07-21
951	951	16	south	9665.80	2023-12-23
952	952	11	south	1517.83	2023-12-25
953	953	9	north	1550.09	2024-04-15
954	954	10	north	5132.55	2024-02-13
955	955	7	north	1523.45	2023-12-04
956	956	20	south	772.63	2024-01-07
957	957	9	north	5205.03	2023-11-23
958	958	13	south	6112.96	2023-09-09
959	959	12	south	6841.87	2024-03-17
960	960	10	north	5158.64	2024-05-03
961	961	2	north	486.57	2024-02-06
962	962	6	north	859.15	2024-01-31
963	963	3	north	4816.74	2023-09-22
964	964	19	south	8416.76	2023-09-13
965	965	12	south	3843.41	2024-04-21
966	966	20	south	5009.83	2024-06-30
967	967	4	north	9487.10	2024-06-29
968	968	20	south	4453.45	2024-06-26
969	969	13	south	7244.23	2023-11-07
970	970	1	north	6232.18	2023-09-28
971	971	11	south	127.56	2023-09-24
972	972	6	north	4767.09	2024-08-09
973	973	17	south	3090.69	2024-06-23
974	974	16	south	6797.23	2024-04-12
975	975	19	south	2957.42	2024-01-13
976	976	13	south	4928.10	2024-06-12
977	977	17	south	2547.40	2023-12-17
978	978	17	south	906.50	2024-02-23
979	979	2	north	616.30	2023-12-27
980	980	12	south	4220.02	2023-12-04
981	981	3	north	8144.58	2024-01-26
982	982	16	south	6724.69	2024-07-13
983	983	3	north	5716.91	2024-05-07
984	984	13	south	4259.85	2023-10-01
985	985	8	north	649.04	2023-10-12
986	986	14	south	5349.41	2023-11-27
987	987	17	south	3193.21	2023-09-03
988	988	5	north	4884.44	2023-10-26
989	989	8	north	7045.03	2024-02-25
990	990	15	south	9792.56	2023-12-07
991	991	3	north	9126.71	2024-07-27
992	992	14	south	5327.30	2024-06-11
993	993	13	south	7491.18	2023-11-29
994	994	12	south	2447.97	2024-01-13
995	995	20	south	6165.27	2024-06-24
996	996	10	north	1255.47	2024-07-18
997	997	6	north	2615.07	2024-07-12
998	998	18	south	5521.67	2024-06-01
999	999	12	south	7642.92	2024-08-07
1000	1000	12	south	9296.47	2024-08-07
\.


--
-- Data for Name: bankbranches_default; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.bankbranches_default (bank_id, bank_region, bank_name, account_num, total_funds) FROM stdin;
\.


--
-- Data for Name: bankbranches_north; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.bankbranches_north (bank_id, bank_region, bank_name, account_num, total_funds) FROM stdin;
1	north	North Branch 1	100	1544887.05
2	north	North Branch 2	100	2195593.45
3	north	North Branch 3	100	6523510.72
4	north	North Branch 4	100	7867036.84
5	north	North Branch 5	100	2283655.85
6	north	North Branch 6	100	3409905.43
7	north	North Branch 7	100	4516246.20
8	north	North Branch 8	100	8628184.92
9	north	North Branch 9	100	1722005.58
10	north	North Branch 10	100	2198775.93
\.


--
-- Data for Name: bankbranches_south; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.bankbranches_south (bank_id, bank_region, bank_name, account_num, total_funds) FROM stdin;
11	south	South Branch 1	100	1967067.33
12	south	South Branch 2	100	7970999.94
13	south	South Branch 3	100	4671409.14
14	south	South Branch 4	100	6932011.15
15	south	South Branch 5	100	1300804.82
16	south	South Branch 6	100	167562.24
17	south	South Branch 7	100	4205944.07
18	south	South Branch 8	100	9417998.61
19	south	South Branch 9	100	5760123.52
20	south	South Branch 10	100	1750018.37
\.


--
-- Data for Name: marketsurvey; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.marketsurvey (survey_id, survey_title, survey_des, survey_response) FROM stdin;
\.


--
-- Data for Name: user_information; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_information (user_id, name, gender, phone, email) FROM stdin;
1	User1	M	123-456-7890	user1@example.com
2	User2	M	123-456-7890	user2@example.com
3	User3	M	123-456-7890	user3@example.com
4	User4	M	123-456-7890	user4@example.com
5	User5	M	123-456-7890	user5@example.com
6	User6	M	123-456-7890	user6@example.com
7	User7	M	123-456-7890	user7@example.com
8	User8	M	123-456-7890	user8@example.com
9	User9	M	123-456-7890	user9@example.com
10	User10	M	123-456-7890	user10@example.com
11	User11	M	123-456-7890	user11@example.com
12	User12	M	123-456-7890	user12@example.com
13	User13	M	123-456-7890	user13@example.com
14	User14	M	123-456-7890	user14@example.com
15	User15	M	123-456-7890	user15@example.com
16	User16	M	123-456-7890	user16@example.com
17	User17	M	123-456-7890	user17@example.com
18	User18	M	123-456-7890	user18@example.com
19	User19	M	123-456-7890	user19@example.com
20	User20	M	123-456-7890	user20@example.com
21	User21	M	123-456-7890	user21@example.com
22	User22	M	123-456-7890	user22@example.com
23	User23	M	123-456-7890	user23@example.com
24	User24	M	123-456-7890	user24@example.com
25	User25	M	123-456-7890	user25@example.com
26	User26	M	123-456-7890	user26@example.com
27	User27	M	123-456-7890	user27@example.com
28	User28	M	123-456-7890	user28@example.com
29	User29	M	123-456-7890	user29@example.com
30	User30	M	123-456-7890	user30@example.com
31	User31	M	123-456-7890	user31@example.com
32	User32	M	123-456-7890	user32@example.com
33	User33	M	123-456-7890	user33@example.com
34	User34	M	123-456-7890	user34@example.com
35	User35	M	123-456-7890	user35@example.com
36	User36	M	123-456-7890	user36@example.com
37	User37	M	123-456-7890	user37@example.com
38	User38	M	123-456-7890	user38@example.com
39	User39	M	123-456-7890	user39@example.com
40	User40	M	123-456-7890	user40@example.com
41	User41	M	123-456-7890	user41@example.com
42	User42	M	123-456-7890	user42@example.com
43	User43	M	123-456-7890	user43@example.com
44	User44	M	123-456-7890	user44@example.com
45	User45	M	123-456-7890	user45@example.com
46	User46	M	123-456-7890	user46@example.com
47	User47	M	123-456-7890	user47@example.com
48	User48	M	123-456-7890	user48@example.com
49	User49	M	123-456-7890	user49@example.com
50	User50	M	123-456-7890	user50@example.com
51	User51	M	123-456-7890	user51@example.com
52	User52	M	123-456-7890	user52@example.com
53	User53	M	123-456-7890	user53@example.com
54	User54	M	123-456-7890	user54@example.com
55	User55	M	123-456-7890	user55@example.com
56	User56	M	123-456-7890	user56@example.com
57	User57	M	123-456-7890	user57@example.com
58	User58	M	123-456-7890	user58@example.com
59	User59	M	123-456-7890	user59@example.com
60	User60	M	123-456-7890	user60@example.com
61	User61	M	123-456-7890	user61@example.com
62	User62	M	123-456-7890	user62@example.com
63	User63	M	123-456-7890	user63@example.com
64	User64	M	123-456-7890	user64@example.com
65	User65	M	123-456-7890	user65@example.com
66	User66	M	123-456-7890	user66@example.com
67	User67	M	123-456-7890	user67@example.com
68	User68	M	123-456-7890	user68@example.com
69	User69	M	123-456-7890	user69@example.com
70	User70	M	123-456-7890	user70@example.com
71	User71	M	123-456-7890	user71@example.com
72	User72	M	123-456-7890	user72@example.com
73	User73	M	123-456-7890	user73@example.com
74	User74	M	123-456-7890	user74@example.com
75	User75	M	123-456-7890	user75@example.com
76	User76	M	123-456-7890	user76@example.com
77	User77	M	123-456-7890	user77@example.com
78	User78	M	123-456-7890	user78@example.com
79	User79	M	123-456-7890	user79@example.com
80	User80	M	123-456-7890	user80@example.com
81	User81	M	123-456-7890	user81@example.com
82	User82	M	123-456-7890	user82@example.com
83	User83	M	123-456-7890	user83@example.com
84	User84	M	123-456-7890	user84@example.com
85	User85	M	123-456-7890	user85@example.com
86	User86	M	123-456-7890	user86@example.com
87	User87	M	123-456-7890	user87@example.com
88	User88	M	123-456-7890	user88@example.com
89	User89	M	123-456-7890	user89@example.com
90	User90	M	123-456-7890	user90@example.com
91	User91	M	123-456-7890	user91@example.com
92	User92	M	123-456-7890	user92@example.com
93	User93	M	123-456-7890	user93@example.com
94	User94	M	123-456-7890	user94@example.com
95	User95	M	123-456-7890	user95@example.com
96	User96	M	123-456-7890	user96@example.com
97	User97	M	123-456-7890	user97@example.com
98	User98	M	123-456-7890	user98@example.com
99	User99	M	123-456-7890	user99@example.com
100	User100	M	123-456-7890	user100@example.com
101	User101	M	123-456-7890	user101@example.com
102	User102	M	123-456-7890	user102@example.com
103	User103	M	123-456-7890	user103@example.com
104	User104	M	123-456-7890	user104@example.com
105	User105	M	123-456-7890	user105@example.com
106	User106	M	123-456-7890	user106@example.com
107	User107	M	123-456-7890	user107@example.com
108	User108	M	123-456-7890	user108@example.com
109	User109	M	123-456-7890	user109@example.com
110	User110	M	123-456-7890	user110@example.com
111	User111	M	123-456-7890	user111@example.com
112	User112	M	123-456-7890	user112@example.com
113	User113	M	123-456-7890	user113@example.com
114	User114	M	123-456-7890	user114@example.com
115	User115	M	123-456-7890	user115@example.com
116	User116	M	123-456-7890	user116@example.com
117	User117	M	123-456-7890	user117@example.com
118	User118	M	123-456-7890	user118@example.com
119	User119	M	123-456-7890	user119@example.com
120	User120	M	123-456-7890	user120@example.com
121	User121	M	123-456-7890	user121@example.com
122	User122	M	123-456-7890	user122@example.com
123	User123	M	123-456-7890	user123@example.com
124	User124	M	123-456-7890	user124@example.com
125	User125	M	123-456-7890	user125@example.com
126	User126	M	123-456-7890	user126@example.com
127	User127	M	123-456-7890	user127@example.com
128	User128	M	123-456-7890	user128@example.com
129	User129	M	123-456-7890	user129@example.com
130	User130	M	123-456-7890	user130@example.com
131	User131	M	123-456-7890	user131@example.com
132	User132	M	123-456-7890	user132@example.com
133	User133	M	123-456-7890	user133@example.com
134	User134	M	123-456-7890	user134@example.com
135	User135	M	123-456-7890	user135@example.com
136	User136	M	123-456-7890	user136@example.com
137	User137	M	123-456-7890	user137@example.com
138	User138	M	123-456-7890	user138@example.com
139	User139	M	123-456-7890	user139@example.com
140	User140	M	123-456-7890	user140@example.com
141	User141	M	123-456-7890	user141@example.com
142	User142	M	123-456-7890	user142@example.com
143	User143	M	123-456-7890	user143@example.com
144	User144	M	123-456-7890	user144@example.com
145	User145	M	123-456-7890	user145@example.com
146	User146	M	123-456-7890	user146@example.com
147	User147	M	123-456-7890	user147@example.com
148	User148	M	123-456-7890	user148@example.com
149	User149	M	123-456-7890	user149@example.com
150	User150	M	123-456-7890	user150@example.com
151	User151	M	123-456-7890	user151@example.com
152	User152	M	123-456-7890	user152@example.com
153	User153	M	123-456-7890	user153@example.com
154	User154	M	123-456-7890	user154@example.com
155	User155	M	123-456-7890	user155@example.com
156	User156	M	123-456-7890	user156@example.com
157	User157	M	123-456-7890	user157@example.com
158	User158	M	123-456-7890	user158@example.com
159	User159	M	123-456-7890	user159@example.com
160	User160	M	123-456-7890	user160@example.com
161	User161	M	123-456-7890	user161@example.com
162	User162	M	123-456-7890	user162@example.com
163	User163	M	123-456-7890	user163@example.com
164	User164	M	123-456-7890	user164@example.com
165	User165	M	123-456-7890	user165@example.com
166	User166	M	123-456-7890	user166@example.com
167	User167	M	123-456-7890	user167@example.com
168	User168	M	123-456-7890	user168@example.com
169	User169	M	123-456-7890	user169@example.com
170	User170	M	123-456-7890	user170@example.com
171	User171	M	123-456-7890	user171@example.com
172	User172	M	123-456-7890	user172@example.com
173	User173	M	123-456-7890	user173@example.com
174	User174	M	123-456-7890	user174@example.com
175	User175	M	123-456-7890	user175@example.com
176	User176	M	123-456-7890	user176@example.com
177	User177	M	123-456-7890	user177@example.com
178	User178	M	123-456-7890	user178@example.com
179	User179	M	123-456-7890	user179@example.com
180	User180	M	123-456-7890	user180@example.com
181	User181	M	123-456-7890	user181@example.com
182	User182	M	123-456-7890	user182@example.com
183	User183	M	123-456-7890	user183@example.com
184	User184	M	123-456-7890	user184@example.com
185	User185	M	123-456-7890	user185@example.com
186	User186	M	123-456-7890	user186@example.com
187	User187	M	123-456-7890	user187@example.com
188	User188	M	123-456-7890	user188@example.com
189	User189	M	123-456-7890	user189@example.com
190	User190	M	123-456-7890	user190@example.com
191	User191	M	123-456-7890	user191@example.com
192	User192	M	123-456-7890	user192@example.com
193	User193	M	123-456-7890	user193@example.com
194	User194	M	123-456-7890	user194@example.com
195	User195	M	123-456-7890	user195@example.com
196	User196	M	123-456-7890	user196@example.com
197	User197	M	123-456-7890	user197@example.com
198	User198	M	123-456-7890	user198@example.com
199	User199	M	123-456-7890	user199@example.com
200	User200	M	123-456-7890	user200@example.com
201	User201	M	123-456-7890	user201@example.com
202	User202	M	123-456-7890	user202@example.com
203	User203	M	123-456-7890	user203@example.com
204	User204	M	123-456-7890	user204@example.com
205	User205	M	123-456-7890	user205@example.com
206	User206	M	123-456-7890	user206@example.com
207	User207	M	123-456-7890	user207@example.com
208	User208	M	123-456-7890	user208@example.com
209	User209	M	123-456-7890	user209@example.com
210	User210	M	123-456-7890	user210@example.com
211	User211	M	123-456-7890	user211@example.com
212	User212	M	123-456-7890	user212@example.com
213	User213	M	123-456-7890	user213@example.com
214	User214	M	123-456-7890	user214@example.com
215	User215	M	123-456-7890	user215@example.com
216	User216	M	123-456-7890	user216@example.com
217	User217	M	123-456-7890	user217@example.com
218	User218	M	123-456-7890	user218@example.com
219	User219	M	123-456-7890	user219@example.com
220	User220	M	123-456-7890	user220@example.com
221	User221	M	123-456-7890	user221@example.com
222	User222	M	123-456-7890	user222@example.com
223	User223	M	123-456-7890	user223@example.com
224	User224	M	123-456-7890	user224@example.com
225	User225	M	123-456-7890	user225@example.com
226	User226	M	123-456-7890	user226@example.com
227	User227	M	123-456-7890	user227@example.com
228	User228	M	123-456-7890	user228@example.com
229	User229	M	123-456-7890	user229@example.com
230	User230	M	123-456-7890	user230@example.com
231	User231	M	123-456-7890	user231@example.com
232	User232	M	123-456-7890	user232@example.com
233	User233	M	123-456-7890	user233@example.com
234	User234	M	123-456-7890	user234@example.com
235	User235	M	123-456-7890	user235@example.com
236	User236	M	123-456-7890	user236@example.com
237	User237	M	123-456-7890	user237@example.com
238	User238	M	123-456-7890	user238@example.com
239	User239	M	123-456-7890	user239@example.com
240	User240	M	123-456-7890	user240@example.com
241	User241	M	123-456-7890	user241@example.com
242	User242	M	123-456-7890	user242@example.com
243	User243	M	123-456-7890	user243@example.com
244	User244	M	123-456-7890	user244@example.com
245	User245	M	123-456-7890	user245@example.com
246	User246	M	123-456-7890	user246@example.com
247	User247	M	123-456-7890	user247@example.com
248	User248	M	123-456-7890	user248@example.com
249	User249	M	123-456-7890	user249@example.com
250	User250	M	123-456-7890	user250@example.com
251	User251	M	123-456-7890	user251@example.com
252	User252	M	123-456-7890	user252@example.com
253	User253	M	123-456-7890	user253@example.com
254	User254	M	123-456-7890	user254@example.com
255	User255	M	123-456-7890	user255@example.com
256	User256	M	123-456-7890	user256@example.com
257	User257	M	123-456-7890	user257@example.com
258	User258	M	123-456-7890	user258@example.com
259	User259	M	123-456-7890	user259@example.com
260	User260	M	123-456-7890	user260@example.com
261	User261	M	123-456-7890	user261@example.com
262	User262	M	123-456-7890	user262@example.com
263	User263	M	123-456-7890	user263@example.com
264	User264	M	123-456-7890	user264@example.com
265	User265	M	123-456-7890	user265@example.com
266	User266	M	123-456-7890	user266@example.com
267	User267	M	123-456-7890	user267@example.com
268	User268	M	123-456-7890	user268@example.com
269	User269	M	123-456-7890	user269@example.com
270	User270	M	123-456-7890	user270@example.com
271	User271	M	123-456-7890	user271@example.com
272	User272	M	123-456-7890	user272@example.com
273	User273	M	123-456-7890	user273@example.com
274	User274	M	123-456-7890	user274@example.com
275	User275	M	123-456-7890	user275@example.com
276	User276	M	123-456-7890	user276@example.com
277	User277	M	123-456-7890	user277@example.com
278	User278	M	123-456-7890	user278@example.com
279	User279	M	123-456-7890	user279@example.com
280	User280	M	123-456-7890	user280@example.com
281	User281	M	123-456-7890	user281@example.com
282	User282	M	123-456-7890	user282@example.com
283	User283	M	123-456-7890	user283@example.com
284	User284	M	123-456-7890	user284@example.com
285	User285	M	123-456-7890	user285@example.com
286	User286	M	123-456-7890	user286@example.com
287	User287	M	123-456-7890	user287@example.com
288	User288	M	123-456-7890	user288@example.com
289	User289	M	123-456-7890	user289@example.com
290	User290	M	123-456-7890	user290@example.com
291	User291	M	123-456-7890	user291@example.com
292	User292	M	123-456-7890	user292@example.com
293	User293	M	123-456-7890	user293@example.com
294	User294	M	123-456-7890	user294@example.com
295	User295	M	123-456-7890	user295@example.com
296	User296	M	123-456-7890	user296@example.com
297	User297	M	123-456-7890	user297@example.com
298	User298	M	123-456-7890	user298@example.com
299	User299	M	123-456-7890	user299@example.com
300	User300	M	123-456-7890	user300@example.com
301	User301	M	123-456-7890	user301@example.com
302	User302	M	123-456-7890	user302@example.com
303	User303	M	123-456-7890	user303@example.com
304	User304	M	123-456-7890	user304@example.com
305	User305	M	123-456-7890	user305@example.com
306	User306	M	123-456-7890	user306@example.com
307	User307	M	123-456-7890	user307@example.com
308	User308	M	123-456-7890	user308@example.com
309	User309	M	123-456-7890	user309@example.com
310	User310	M	123-456-7890	user310@example.com
311	User311	M	123-456-7890	user311@example.com
312	User312	M	123-456-7890	user312@example.com
313	User313	M	123-456-7890	user313@example.com
314	User314	M	123-456-7890	user314@example.com
315	User315	M	123-456-7890	user315@example.com
316	User316	M	123-456-7890	user316@example.com
317	User317	M	123-456-7890	user317@example.com
318	User318	M	123-456-7890	user318@example.com
319	User319	M	123-456-7890	user319@example.com
320	User320	M	123-456-7890	user320@example.com
321	User321	M	123-456-7890	user321@example.com
322	User322	M	123-456-7890	user322@example.com
323	User323	M	123-456-7890	user323@example.com
324	User324	M	123-456-7890	user324@example.com
325	User325	M	123-456-7890	user325@example.com
326	User326	M	123-456-7890	user326@example.com
327	User327	M	123-456-7890	user327@example.com
328	User328	M	123-456-7890	user328@example.com
329	User329	M	123-456-7890	user329@example.com
330	User330	M	123-456-7890	user330@example.com
331	User331	M	123-456-7890	user331@example.com
332	User332	M	123-456-7890	user332@example.com
333	User333	M	123-456-7890	user333@example.com
334	User334	M	123-456-7890	user334@example.com
335	User335	M	123-456-7890	user335@example.com
336	User336	M	123-456-7890	user336@example.com
337	User337	M	123-456-7890	user337@example.com
338	User338	M	123-456-7890	user338@example.com
339	User339	M	123-456-7890	user339@example.com
340	User340	M	123-456-7890	user340@example.com
341	User341	M	123-456-7890	user341@example.com
342	User342	M	123-456-7890	user342@example.com
343	User343	M	123-456-7890	user343@example.com
344	User344	M	123-456-7890	user344@example.com
345	User345	M	123-456-7890	user345@example.com
346	User346	M	123-456-7890	user346@example.com
347	User347	M	123-456-7890	user347@example.com
348	User348	M	123-456-7890	user348@example.com
349	User349	M	123-456-7890	user349@example.com
350	User350	M	123-456-7890	user350@example.com
351	User351	M	123-456-7890	user351@example.com
352	User352	M	123-456-7890	user352@example.com
353	User353	M	123-456-7890	user353@example.com
354	User354	M	123-456-7890	user354@example.com
355	User355	M	123-456-7890	user355@example.com
356	User356	M	123-456-7890	user356@example.com
357	User357	M	123-456-7890	user357@example.com
358	User358	M	123-456-7890	user358@example.com
359	User359	M	123-456-7890	user359@example.com
360	User360	M	123-456-7890	user360@example.com
361	User361	M	123-456-7890	user361@example.com
362	User362	M	123-456-7890	user362@example.com
363	User363	M	123-456-7890	user363@example.com
364	User364	M	123-456-7890	user364@example.com
365	User365	M	123-456-7890	user365@example.com
366	User366	M	123-456-7890	user366@example.com
367	User367	M	123-456-7890	user367@example.com
368	User368	M	123-456-7890	user368@example.com
369	User369	M	123-456-7890	user369@example.com
370	User370	M	123-456-7890	user370@example.com
371	User371	M	123-456-7890	user371@example.com
372	User372	M	123-456-7890	user372@example.com
373	User373	M	123-456-7890	user373@example.com
374	User374	M	123-456-7890	user374@example.com
375	User375	M	123-456-7890	user375@example.com
376	User376	M	123-456-7890	user376@example.com
377	User377	M	123-456-7890	user377@example.com
378	User378	M	123-456-7890	user378@example.com
379	User379	M	123-456-7890	user379@example.com
380	User380	M	123-456-7890	user380@example.com
381	User381	M	123-456-7890	user381@example.com
382	User382	M	123-456-7890	user382@example.com
383	User383	M	123-456-7890	user383@example.com
384	User384	M	123-456-7890	user384@example.com
385	User385	M	123-456-7890	user385@example.com
386	User386	M	123-456-7890	user386@example.com
387	User387	M	123-456-7890	user387@example.com
388	User388	M	123-456-7890	user388@example.com
389	User389	M	123-456-7890	user389@example.com
390	User390	M	123-456-7890	user390@example.com
391	User391	M	123-456-7890	user391@example.com
392	User392	M	123-456-7890	user392@example.com
393	User393	M	123-456-7890	user393@example.com
394	User394	M	123-456-7890	user394@example.com
395	User395	M	123-456-7890	user395@example.com
396	User396	M	123-456-7890	user396@example.com
397	User397	M	123-456-7890	user397@example.com
398	User398	M	123-456-7890	user398@example.com
399	User399	M	123-456-7890	user399@example.com
400	User400	M	123-456-7890	user400@example.com
401	User401	M	123-456-7890	user401@example.com
402	User402	M	123-456-7890	user402@example.com
403	User403	M	123-456-7890	user403@example.com
404	User404	M	123-456-7890	user404@example.com
405	User405	M	123-456-7890	user405@example.com
406	User406	M	123-456-7890	user406@example.com
407	User407	M	123-456-7890	user407@example.com
408	User408	M	123-456-7890	user408@example.com
409	User409	M	123-456-7890	user409@example.com
410	User410	M	123-456-7890	user410@example.com
411	User411	M	123-456-7890	user411@example.com
412	User412	M	123-456-7890	user412@example.com
413	User413	M	123-456-7890	user413@example.com
414	User414	M	123-456-7890	user414@example.com
415	User415	M	123-456-7890	user415@example.com
416	User416	M	123-456-7890	user416@example.com
417	User417	M	123-456-7890	user417@example.com
418	User418	M	123-456-7890	user418@example.com
419	User419	M	123-456-7890	user419@example.com
420	User420	M	123-456-7890	user420@example.com
421	User421	M	123-456-7890	user421@example.com
422	User422	M	123-456-7890	user422@example.com
423	User423	M	123-456-7890	user423@example.com
424	User424	M	123-456-7890	user424@example.com
425	User425	M	123-456-7890	user425@example.com
426	User426	M	123-456-7890	user426@example.com
427	User427	M	123-456-7890	user427@example.com
428	User428	M	123-456-7890	user428@example.com
429	User429	M	123-456-7890	user429@example.com
430	User430	M	123-456-7890	user430@example.com
431	User431	M	123-456-7890	user431@example.com
432	User432	M	123-456-7890	user432@example.com
433	User433	M	123-456-7890	user433@example.com
434	User434	M	123-456-7890	user434@example.com
435	User435	M	123-456-7890	user435@example.com
436	User436	M	123-456-7890	user436@example.com
437	User437	M	123-456-7890	user437@example.com
438	User438	M	123-456-7890	user438@example.com
439	User439	M	123-456-7890	user439@example.com
440	User440	M	123-456-7890	user440@example.com
441	User441	M	123-456-7890	user441@example.com
442	User442	M	123-456-7890	user442@example.com
443	User443	M	123-456-7890	user443@example.com
444	User444	M	123-456-7890	user444@example.com
445	User445	M	123-456-7890	user445@example.com
446	User446	M	123-456-7890	user446@example.com
447	User447	M	123-456-7890	user447@example.com
448	User448	M	123-456-7890	user448@example.com
449	User449	M	123-456-7890	user449@example.com
450	User450	M	123-456-7890	user450@example.com
451	User451	M	123-456-7890	user451@example.com
452	User452	M	123-456-7890	user452@example.com
453	User453	M	123-456-7890	user453@example.com
454	User454	M	123-456-7890	user454@example.com
455	User455	M	123-456-7890	user455@example.com
456	User456	M	123-456-7890	user456@example.com
457	User457	M	123-456-7890	user457@example.com
458	User458	M	123-456-7890	user458@example.com
459	User459	M	123-456-7890	user459@example.com
460	User460	M	123-456-7890	user460@example.com
461	User461	M	123-456-7890	user461@example.com
462	User462	M	123-456-7890	user462@example.com
463	User463	M	123-456-7890	user463@example.com
464	User464	M	123-456-7890	user464@example.com
465	User465	M	123-456-7890	user465@example.com
466	User466	M	123-456-7890	user466@example.com
467	User467	M	123-456-7890	user467@example.com
468	User468	M	123-456-7890	user468@example.com
469	User469	M	123-456-7890	user469@example.com
470	User470	M	123-456-7890	user470@example.com
471	User471	M	123-456-7890	user471@example.com
472	User472	M	123-456-7890	user472@example.com
473	User473	M	123-456-7890	user473@example.com
474	User474	M	123-456-7890	user474@example.com
475	User475	M	123-456-7890	user475@example.com
476	User476	M	123-456-7890	user476@example.com
477	User477	M	123-456-7890	user477@example.com
478	User478	M	123-456-7890	user478@example.com
479	User479	M	123-456-7890	user479@example.com
480	User480	M	123-456-7890	user480@example.com
481	User481	M	123-456-7890	user481@example.com
482	User482	M	123-456-7890	user482@example.com
483	User483	M	123-456-7890	user483@example.com
484	User484	M	123-456-7890	user484@example.com
485	User485	M	123-456-7890	user485@example.com
486	User486	M	123-456-7890	user486@example.com
487	User487	M	123-456-7890	user487@example.com
488	User488	M	123-456-7890	user488@example.com
489	User489	M	123-456-7890	user489@example.com
490	User490	M	123-456-7890	user490@example.com
491	User491	M	123-456-7890	user491@example.com
492	User492	M	123-456-7890	user492@example.com
493	User493	M	123-456-7890	user493@example.com
494	User494	M	123-456-7890	user494@example.com
495	User495	M	123-456-7890	user495@example.com
496	User496	M	123-456-7890	user496@example.com
497	User497	M	123-456-7890	user497@example.com
498	User498	M	123-456-7890	user498@example.com
499	User499	M	123-456-7890	user499@example.com
500	User500	M	123-456-7890	user500@example.com
501	User501	M	123-456-7890	user501@example.com
502	User502	M	123-456-7890	user502@example.com
503	User503	M	123-456-7890	user503@example.com
504	User504	M	123-456-7890	user504@example.com
505	User505	M	123-456-7890	user505@example.com
506	User506	M	123-456-7890	user506@example.com
507	User507	M	123-456-7890	user507@example.com
508	User508	M	123-456-7890	user508@example.com
509	User509	M	123-456-7890	user509@example.com
510	User510	M	123-456-7890	user510@example.com
511	User511	M	123-456-7890	user511@example.com
512	User512	M	123-456-7890	user512@example.com
513	User513	M	123-456-7890	user513@example.com
514	User514	M	123-456-7890	user514@example.com
515	User515	M	123-456-7890	user515@example.com
516	User516	M	123-456-7890	user516@example.com
517	User517	M	123-456-7890	user517@example.com
518	User518	M	123-456-7890	user518@example.com
519	User519	M	123-456-7890	user519@example.com
520	User520	M	123-456-7890	user520@example.com
521	User521	M	123-456-7890	user521@example.com
522	User522	M	123-456-7890	user522@example.com
523	User523	M	123-456-7890	user523@example.com
524	User524	M	123-456-7890	user524@example.com
525	User525	M	123-456-7890	user525@example.com
526	User526	M	123-456-7890	user526@example.com
527	User527	M	123-456-7890	user527@example.com
528	User528	M	123-456-7890	user528@example.com
529	User529	M	123-456-7890	user529@example.com
530	User530	M	123-456-7890	user530@example.com
531	User531	M	123-456-7890	user531@example.com
532	User532	M	123-456-7890	user532@example.com
533	User533	M	123-456-7890	user533@example.com
534	User534	M	123-456-7890	user534@example.com
535	User535	M	123-456-7890	user535@example.com
536	User536	M	123-456-7890	user536@example.com
537	User537	M	123-456-7890	user537@example.com
538	User538	M	123-456-7890	user538@example.com
539	User539	M	123-456-7890	user539@example.com
540	User540	M	123-456-7890	user540@example.com
541	User541	M	123-456-7890	user541@example.com
542	User542	M	123-456-7890	user542@example.com
543	User543	M	123-456-7890	user543@example.com
544	User544	M	123-456-7890	user544@example.com
545	User545	M	123-456-7890	user545@example.com
546	User546	M	123-456-7890	user546@example.com
547	User547	M	123-456-7890	user547@example.com
548	User548	M	123-456-7890	user548@example.com
549	User549	M	123-456-7890	user549@example.com
550	User550	M	123-456-7890	user550@example.com
551	User551	M	123-456-7890	user551@example.com
552	User552	M	123-456-7890	user552@example.com
553	User553	M	123-456-7890	user553@example.com
554	User554	M	123-456-7890	user554@example.com
555	User555	M	123-456-7890	user555@example.com
556	User556	M	123-456-7890	user556@example.com
557	User557	M	123-456-7890	user557@example.com
558	User558	M	123-456-7890	user558@example.com
559	User559	M	123-456-7890	user559@example.com
560	User560	M	123-456-7890	user560@example.com
561	User561	M	123-456-7890	user561@example.com
562	User562	M	123-456-7890	user562@example.com
563	User563	M	123-456-7890	user563@example.com
564	User564	M	123-456-7890	user564@example.com
565	User565	M	123-456-7890	user565@example.com
566	User566	M	123-456-7890	user566@example.com
567	User567	M	123-456-7890	user567@example.com
568	User568	M	123-456-7890	user568@example.com
569	User569	M	123-456-7890	user569@example.com
570	User570	M	123-456-7890	user570@example.com
571	User571	M	123-456-7890	user571@example.com
572	User572	M	123-456-7890	user572@example.com
573	User573	M	123-456-7890	user573@example.com
574	User574	M	123-456-7890	user574@example.com
575	User575	M	123-456-7890	user575@example.com
576	User576	M	123-456-7890	user576@example.com
577	User577	M	123-456-7890	user577@example.com
578	User578	M	123-456-7890	user578@example.com
579	User579	M	123-456-7890	user579@example.com
580	User580	M	123-456-7890	user580@example.com
581	User581	M	123-456-7890	user581@example.com
582	User582	M	123-456-7890	user582@example.com
583	User583	M	123-456-7890	user583@example.com
584	User584	M	123-456-7890	user584@example.com
585	User585	M	123-456-7890	user585@example.com
586	User586	M	123-456-7890	user586@example.com
587	User587	M	123-456-7890	user587@example.com
588	User588	M	123-456-7890	user588@example.com
589	User589	M	123-456-7890	user589@example.com
590	User590	M	123-456-7890	user590@example.com
591	User591	M	123-456-7890	user591@example.com
592	User592	M	123-456-7890	user592@example.com
593	User593	M	123-456-7890	user593@example.com
594	User594	M	123-456-7890	user594@example.com
595	User595	M	123-456-7890	user595@example.com
596	User596	M	123-456-7890	user596@example.com
597	User597	M	123-456-7890	user597@example.com
598	User598	M	123-456-7890	user598@example.com
599	User599	M	123-456-7890	user599@example.com
600	User600	M	123-456-7890	user600@example.com
601	User601	M	123-456-7890	user601@example.com
602	User602	M	123-456-7890	user602@example.com
603	User603	M	123-456-7890	user603@example.com
604	User604	M	123-456-7890	user604@example.com
605	User605	M	123-456-7890	user605@example.com
606	User606	M	123-456-7890	user606@example.com
607	User607	M	123-456-7890	user607@example.com
608	User608	M	123-456-7890	user608@example.com
609	User609	M	123-456-7890	user609@example.com
610	User610	M	123-456-7890	user610@example.com
611	User611	M	123-456-7890	user611@example.com
612	User612	M	123-456-7890	user612@example.com
613	User613	M	123-456-7890	user613@example.com
614	User614	M	123-456-7890	user614@example.com
615	User615	M	123-456-7890	user615@example.com
616	User616	M	123-456-7890	user616@example.com
617	User617	M	123-456-7890	user617@example.com
618	User618	M	123-456-7890	user618@example.com
619	User619	M	123-456-7890	user619@example.com
620	User620	M	123-456-7890	user620@example.com
621	User621	M	123-456-7890	user621@example.com
622	User622	M	123-456-7890	user622@example.com
623	User623	M	123-456-7890	user623@example.com
624	User624	M	123-456-7890	user624@example.com
625	User625	M	123-456-7890	user625@example.com
626	User626	M	123-456-7890	user626@example.com
627	User627	M	123-456-7890	user627@example.com
628	User628	M	123-456-7890	user628@example.com
629	User629	M	123-456-7890	user629@example.com
630	User630	M	123-456-7890	user630@example.com
631	User631	M	123-456-7890	user631@example.com
632	User632	M	123-456-7890	user632@example.com
633	User633	M	123-456-7890	user633@example.com
634	User634	M	123-456-7890	user634@example.com
635	User635	M	123-456-7890	user635@example.com
636	User636	M	123-456-7890	user636@example.com
637	User637	M	123-456-7890	user637@example.com
638	User638	M	123-456-7890	user638@example.com
639	User639	M	123-456-7890	user639@example.com
640	User640	M	123-456-7890	user640@example.com
641	User641	M	123-456-7890	user641@example.com
642	User642	M	123-456-7890	user642@example.com
643	User643	M	123-456-7890	user643@example.com
644	User644	M	123-456-7890	user644@example.com
645	User645	M	123-456-7890	user645@example.com
646	User646	M	123-456-7890	user646@example.com
647	User647	M	123-456-7890	user647@example.com
648	User648	M	123-456-7890	user648@example.com
649	User649	M	123-456-7890	user649@example.com
650	User650	M	123-456-7890	user650@example.com
651	User651	M	123-456-7890	user651@example.com
652	User652	M	123-456-7890	user652@example.com
653	User653	M	123-456-7890	user653@example.com
654	User654	M	123-456-7890	user654@example.com
655	User655	M	123-456-7890	user655@example.com
656	User656	M	123-456-7890	user656@example.com
657	User657	M	123-456-7890	user657@example.com
658	User658	M	123-456-7890	user658@example.com
659	User659	M	123-456-7890	user659@example.com
660	User660	M	123-456-7890	user660@example.com
661	User661	M	123-456-7890	user661@example.com
662	User662	M	123-456-7890	user662@example.com
663	User663	M	123-456-7890	user663@example.com
664	User664	M	123-456-7890	user664@example.com
665	User665	M	123-456-7890	user665@example.com
666	User666	M	123-456-7890	user666@example.com
667	User667	M	123-456-7890	user667@example.com
668	User668	M	123-456-7890	user668@example.com
669	User669	M	123-456-7890	user669@example.com
670	User670	M	123-456-7890	user670@example.com
671	User671	M	123-456-7890	user671@example.com
672	User672	M	123-456-7890	user672@example.com
673	User673	M	123-456-7890	user673@example.com
674	User674	M	123-456-7890	user674@example.com
675	User675	M	123-456-7890	user675@example.com
676	User676	M	123-456-7890	user676@example.com
677	User677	M	123-456-7890	user677@example.com
678	User678	M	123-456-7890	user678@example.com
679	User679	M	123-456-7890	user679@example.com
680	User680	M	123-456-7890	user680@example.com
681	User681	M	123-456-7890	user681@example.com
682	User682	M	123-456-7890	user682@example.com
683	User683	M	123-456-7890	user683@example.com
684	User684	M	123-456-7890	user684@example.com
685	User685	M	123-456-7890	user685@example.com
686	User686	M	123-456-7890	user686@example.com
687	User687	M	123-456-7890	user687@example.com
688	User688	M	123-456-7890	user688@example.com
689	User689	M	123-456-7890	user689@example.com
690	User690	M	123-456-7890	user690@example.com
691	User691	M	123-456-7890	user691@example.com
692	User692	M	123-456-7890	user692@example.com
693	User693	M	123-456-7890	user693@example.com
694	User694	M	123-456-7890	user694@example.com
695	User695	M	123-456-7890	user695@example.com
696	User696	M	123-456-7890	user696@example.com
697	User697	M	123-456-7890	user697@example.com
698	User698	M	123-456-7890	user698@example.com
699	User699	M	123-456-7890	user699@example.com
700	User700	M	123-456-7890	user700@example.com
701	User701	M	123-456-7890	user701@example.com
702	User702	M	123-456-7890	user702@example.com
703	User703	M	123-456-7890	user703@example.com
704	User704	M	123-456-7890	user704@example.com
705	User705	M	123-456-7890	user705@example.com
706	User706	M	123-456-7890	user706@example.com
707	User707	M	123-456-7890	user707@example.com
708	User708	M	123-456-7890	user708@example.com
709	User709	M	123-456-7890	user709@example.com
710	User710	M	123-456-7890	user710@example.com
711	User711	M	123-456-7890	user711@example.com
712	User712	M	123-456-7890	user712@example.com
713	User713	M	123-456-7890	user713@example.com
714	User714	M	123-456-7890	user714@example.com
715	User715	M	123-456-7890	user715@example.com
716	User716	M	123-456-7890	user716@example.com
717	User717	M	123-456-7890	user717@example.com
718	User718	M	123-456-7890	user718@example.com
719	User719	M	123-456-7890	user719@example.com
720	User720	M	123-456-7890	user720@example.com
721	User721	M	123-456-7890	user721@example.com
722	User722	M	123-456-7890	user722@example.com
723	User723	M	123-456-7890	user723@example.com
724	User724	M	123-456-7890	user724@example.com
725	User725	M	123-456-7890	user725@example.com
726	User726	M	123-456-7890	user726@example.com
727	User727	M	123-456-7890	user727@example.com
728	User728	M	123-456-7890	user728@example.com
729	User729	M	123-456-7890	user729@example.com
730	User730	M	123-456-7890	user730@example.com
731	User731	M	123-456-7890	user731@example.com
732	User732	M	123-456-7890	user732@example.com
733	User733	M	123-456-7890	user733@example.com
734	User734	M	123-456-7890	user734@example.com
735	User735	M	123-456-7890	user735@example.com
736	User736	M	123-456-7890	user736@example.com
737	User737	M	123-456-7890	user737@example.com
738	User738	M	123-456-7890	user738@example.com
739	User739	M	123-456-7890	user739@example.com
740	User740	M	123-456-7890	user740@example.com
741	User741	M	123-456-7890	user741@example.com
742	User742	M	123-456-7890	user742@example.com
743	User743	M	123-456-7890	user743@example.com
744	User744	M	123-456-7890	user744@example.com
745	User745	M	123-456-7890	user745@example.com
746	User746	M	123-456-7890	user746@example.com
747	User747	M	123-456-7890	user747@example.com
748	User748	M	123-456-7890	user748@example.com
749	User749	M	123-456-7890	user749@example.com
750	User750	M	123-456-7890	user750@example.com
751	User751	M	123-456-7890	user751@example.com
752	User752	M	123-456-7890	user752@example.com
753	User753	M	123-456-7890	user753@example.com
754	User754	M	123-456-7890	user754@example.com
755	User755	M	123-456-7890	user755@example.com
756	User756	M	123-456-7890	user756@example.com
757	User757	M	123-456-7890	user757@example.com
758	User758	M	123-456-7890	user758@example.com
759	User759	M	123-456-7890	user759@example.com
760	User760	M	123-456-7890	user760@example.com
761	User761	M	123-456-7890	user761@example.com
762	User762	M	123-456-7890	user762@example.com
763	User763	M	123-456-7890	user763@example.com
764	User764	M	123-456-7890	user764@example.com
765	User765	M	123-456-7890	user765@example.com
766	User766	M	123-456-7890	user766@example.com
767	User767	M	123-456-7890	user767@example.com
768	User768	M	123-456-7890	user768@example.com
769	User769	M	123-456-7890	user769@example.com
770	User770	M	123-456-7890	user770@example.com
771	User771	M	123-456-7890	user771@example.com
772	User772	M	123-456-7890	user772@example.com
773	User773	M	123-456-7890	user773@example.com
774	User774	M	123-456-7890	user774@example.com
775	User775	M	123-456-7890	user775@example.com
776	User776	M	123-456-7890	user776@example.com
777	User777	M	123-456-7890	user777@example.com
778	User778	M	123-456-7890	user778@example.com
779	User779	M	123-456-7890	user779@example.com
780	User780	M	123-456-7890	user780@example.com
781	User781	M	123-456-7890	user781@example.com
782	User782	M	123-456-7890	user782@example.com
783	User783	M	123-456-7890	user783@example.com
784	User784	M	123-456-7890	user784@example.com
785	User785	M	123-456-7890	user785@example.com
786	User786	M	123-456-7890	user786@example.com
787	User787	M	123-456-7890	user787@example.com
788	User788	M	123-456-7890	user788@example.com
789	User789	M	123-456-7890	user789@example.com
790	User790	M	123-456-7890	user790@example.com
791	User791	M	123-456-7890	user791@example.com
792	User792	M	123-456-7890	user792@example.com
793	User793	M	123-456-7890	user793@example.com
794	User794	M	123-456-7890	user794@example.com
795	User795	M	123-456-7890	user795@example.com
796	User796	M	123-456-7890	user796@example.com
797	User797	M	123-456-7890	user797@example.com
798	User798	M	123-456-7890	user798@example.com
799	User799	M	123-456-7890	user799@example.com
800	User800	M	123-456-7890	user800@example.com
801	User801	M	123-456-7890	user801@example.com
802	User802	M	123-456-7890	user802@example.com
803	User803	M	123-456-7890	user803@example.com
804	User804	M	123-456-7890	user804@example.com
805	User805	M	123-456-7890	user805@example.com
806	User806	M	123-456-7890	user806@example.com
807	User807	M	123-456-7890	user807@example.com
808	User808	M	123-456-7890	user808@example.com
809	User809	M	123-456-7890	user809@example.com
810	User810	M	123-456-7890	user810@example.com
811	User811	M	123-456-7890	user811@example.com
812	User812	M	123-456-7890	user812@example.com
813	User813	M	123-456-7890	user813@example.com
814	User814	M	123-456-7890	user814@example.com
815	User815	M	123-456-7890	user815@example.com
816	User816	M	123-456-7890	user816@example.com
817	User817	M	123-456-7890	user817@example.com
818	User818	M	123-456-7890	user818@example.com
819	User819	M	123-456-7890	user819@example.com
820	User820	M	123-456-7890	user820@example.com
821	User821	M	123-456-7890	user821@example.com
822	User822	M	123-456-7890	user822@example.com
823	User823	M	123-456-7890	user823@example.com
824	User824	M	123-456-7890	user824@example.com
825	User825	M	123-456-7890	user825@example.com
826	User826	M	123-456-7890	user826@example.com
827	User827	M	123-456-7890	user827@example.com
828	User828	M	123-456-7890	user828@example.com
829	User829	M	123-456-7890	user829@example.com
830	User830	M	123-456-7890	user830@example.com
831	User831	M	123-456-7890	user831@example.com
832	User832	M	123-456-7890	user832@example.com
833	User833	M	123-456-7890	user833@example.com
834	User834	M	123-456-7890	user834@example.com
835	User835	M	123-456-7890	user835@example.com
836	User836	M	123-456-7890	user836@example.com
837	User837	M	123-456-7890	user837@example.com
838	User838	M	123-456-7890	user838@example.com
839	User839	M	123-456-7890	user839@example.com
840	User840	M	123-456-7890	user840@example.com
841	User841	M	123-456-7890	user841@example.com
842	User842	M	123-456-7890	user842@example.com
843	User843	M	123-456-7890	user843@example.com
844	User844	M	123-456-7890	user844@example.com
845	User845	M	123-456-7890	user845@example.com
846	User846	M	123-456-7890	user846@example.com
847	User847	M	123-456-7890	user847@example.com
848	User848	M	123-456-7890	user848@example.com
849	User849	M	123-456-7890	user849@example.com
850	User850	M	123-456-7890	user850@example.com
851	User851	M	123-456-7890	user851@example.com
852	User852	M	123-456-7890	user852@example.com
853	User853	M	123-456-7890	user853@example.com
854	User854	M	123-456-7890	user854@example.com
855	User855	M	123-456-7890	user855@example.com
856	User856	M	123-456-7890	user856@example.com
857	User857	M	123-456-7890	user857@example.com
858	User858	M	123-456-7890	user858@example.com
859	User859	M	123-456-7890	user859@example.com
860	User860	M	123-456-7890	user860@example.com
861	User861	M	123-456-7890	user861@example.com
862	User862	M	123-456-7890	user862@example.com
863	User863	M	123-456-7890	user863@example.com
864	User864	M	123-456-7890	user864@example.com
865	User865	M	123-456-7890	user865@example.com
866	User866	M	123-456-7890	user866@example.com
867	User867	M	123-456-7890	user867@example.com
868	User868	M	123-456-7890	user868@example.com
869	User869	M	123-456-7890	user869@example.com
870	User870	M	123-456-7890	user870@example.com
871	User871	M	123-456-7890	user871@example.com
872	User872	M	123-456-7890	user872@example.com
873	User873	M	123-456-7890	user873@example.com
874	User874	M	123-456-7890	user874@example.com
875	User875	M	123-456-7890	user875@example.com
876	User876	M	123-456-7890	user876@example.com
877	User877	M	123-456-7890	user877@example.com
878	User878	M	123-456-7890	user878@example.com
879	User879	M	123-456-7890	user879@example.com
880	User880	M	123-456-7890	user880@example.com
881	User881	M	123-456-7890	user881@example.com
882	User882	M	123-456-7890	user882@example.com
883	User883	M	123-456-7890	user883@example.com
884	User884	M	123-456-7890	user884@example.com
885	User885	M	123-456-7890	user885@example.com
886	User886	M	123-456-7890	user886@example.com
887	User887	M	123-456-7890	user887@example.com
888	User888	M	123-456-7890	user888@example.com
889	User889	M	123-456-7890	user889@example.com
890	User890	M	123-456-7890	user890@example.com
891	User891	M	123-456-7890	user891@example.com
892	User892	M	123-456-7890	user892@example.com
893	User893	M	123-456-7890	user893@example.com
894	User894	M	123-456-7890	user894@example.com
895	User895	M	123-456-7890	user895@example.com
896	User896	M	123-456-7890	user896@example.com
897	User897	M	123-456-7890	user897@example.com
898	User898	M	123-456-7890	user898@example.com
899	User899	M	123-456-7890	user899@example.com
900	User900	M	123-456-7890	user900@example.com
901	User901	M	123-456-7890	user901@example.com
902	User902	M	123-456-7890	user902@example.com
903	User903	M	123-456-7890	user903@example.com
904	User904	M	123-456-7890	user904@example.com
905	User905	M	123-456-7890	user905@example.com
906	User906	M	123-456-7890	user906@example.com
907	User907	M	123-456-7890	user907@example.com
908	User908	M	123-456-7890	user908@example.com
909	User909	M	123-456-7890	user909@example.com
910	User910	M	123-456-7890	user910@example.com
911	User911	M	123-456-7890	user911@example.com
912	User912	M	123-456-7890	user912@example.com
913	User913	M	123-456-7890	user913@example.com
914	User914	M	123-456-7890	user914@example.com
915	User915	M	123-456-7890	user915@example.com
916	User916	M	123-456-7890	user916@example.com
917	User917	M	123-456-7890	user917@example.com
918	User918	M	123-456-7890	user918@example.com
919	User919	M	123-456-7890	user919@example.com
920	User920	M	123-456-7890	user920@example.com
921	User921	M	123-456-7890	user921@example.com
922	User922	M	123-456-7890	user922@example.com
923	User923	M	123-456-7890	user923@example.com
924	User924	M	123-456-7890	user924@example.com
925	User925	M	123-456-7890	user925@example.com
926	User926	M	123-456-7890	user926@example.com
927	User927	M	123-456-7890	user927@example.com
928	User928	M	123-456-7890	user928@example.com
929	User929	M	123-456-7890	user929@example.com
930	User930	M	123-456-7890	user930@example.com
931	User931	M	123-456-7890	user931@example.com
932	User932	M	123-456-7890	user932@example.com
933	User933	M	123-456-7890	user933@example.com
934	User934	M	123-456-7890	user934@example.com
935	User935	M	123-456-7890	user935@example.com
936	User936	M	123-456-7890	user936@example.com
937	User937	M	123-456-7890	user937@example.com
938	User938	M	123-456-7890	user938@example.com
939	User939	M	123-456-7890	user939@example.com
940	User940	M	123-456-7890	user940@example.com
941	User941	M	123-456-7890	user941@example.com
942	User942	M	123-456-7890	user942@example.com
943	User943	M	123-456-7890	user943@example.com
944	User944	M	123-456-7890	user944@example.com
945	User945	M	123-456-7890	user945@example.com
946	User946	M	123-456-7890	user946@example.com
947	User947	M	123-456-7890	user947@example.com
948	User948	M	123-456-7890	user948@example.com
949	User949	M	123-456-7890	user949@example.com
950	User950	M	123-456-7890	user950@example.com
951	User951	M	123-456-7890	user951@example.com
952	User952	M	123-456-7890	user952@example.com
953	User953	M	123-456-7890	user953@example.com
954	User954	M	123-456-7890	user954@example.com
955	User955	M	123-456-7890	user955@example.com
956	User956	M	123-456-7890	user956@example.com
957	User957	M	123-456-7890	user957@example.com
958	User958	M	123-456-7890	user958@example.com
959	User959	M	123-456-7890	user959@example.com
960	User960	M	123-456-7890	user960@example.com
961	User961	M	123-456-7890	user961@example.com
962	User962	M	123-456-7890	user962@example.com
963	User963	M	123-456-7890	user963@example.com
964	User964	M	123-456-7890	user964@example.com
965	User965	M	123-456-7890	user965@example.com
966	User966	M	123-456-7890	user966@example.com
967	User967	M	123-456-7890	user967@example.com
968	User968	M	123-456-7890	user968@example.com
969	User969	M	123-456-7890	user969@example.com
970	User970	M	123-456-7890	user970@example.com
971	User971	M	123-456-7890	user971@example.com
972	User972	M	123-456-7890	user972@example.com
973	User973	M	123-456-7890	user973@example.com
974	User974	M	123-456-7890	user974@example.com
975	User975	M	123-456-7890	user975@example.com
976	User976	M	123-456-7890	user976@example.com
977	User977	M	123-456-7890	user977@example.com
978	User978	M	123-456-7890	user978@example.com
979	User979	M	123-456-7890	user979@example.com
980	User980	M	123-456-7890	user980@example.com
981	User981	M	123-456-7890	user981@example.com
982	User982	M	123-456-7890	user982@example.com
983	User983	M	123-456-7890	user983@example.com
984	User984	M	123-456-7890	user984@example.com
985	User985	M	123-456-7890	user985@example.com
986	User986	M	123-456-7890	user986@example.com
987	User987	M	123-456-7890	user987@example.com
988	User988	M	123-456-7890	user988@example.com
989	User989	M	123-456-7890	user989@example.com
990	User990	M	123-456-7890	user990@example.com
991	User991	M	123-456-7890	user991@example.com
992	User992	M	123-456-7890	user992@example.com
993	User993	M	123-456-7890	user993@example.com
994	User994	M	123-456-7890	user994@example.com
995	User995	M	123-456-7890	user995@example.com
996	User996	M	123-456-7890	user996@example.com
997	User997	M	123-456-7890	user997@example.com
998	User998	M	123-456-7890	user998@example.com
999	User999	M	123-456-7890	user999@example.com
1000	User1000	M	123-456-7890	user1000@example.com
\.


--
-- Name: account_cred_his_his_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.account_cred_his_his_id_seq', 1, false);


--
-- Name: account_info_trans_history_trans_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.account_info_trans_history_trans_id_seq', 1, false);


--
-- Name: account_information_account_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.account_information_account_id_seq', 1000, true);


--
-- Name: bankbranches_bank_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.bankbranches_bank_id_seq', 20, true);


--
-- Name: marketsurvey_survey_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.marketsurvey_survey_id_seq', 1, false);


--
-- Name: user_information_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_information_user_id_seq', 1000, true);


--
-- Name: account_cred_his account_cred_his_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_cred_his
    ADD CONSTRAINT account_cred_his_pkey PRIMARY KEY (his_id);


--
-- Name: account_info_trans_history account_info_trans_history_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_info_trans_history
    ADD CONSTRAINT account_info_trans_history_pkey PRIMARY KEY (trans_id);


--
-- Name: account_information account_information_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_information
    ADD CONSTRAINT account_information_pkey PRIMARY KEY (account_id);


--
-- Name: bankbranches bankbranches_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bankbranches
    ADD CONSTRAINT bankbranches_pkey PRIMARY KEY (bank_id, bank_region);


--
-- Name: bankbranches_default bankbranches_default_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bankbranches_default
    ADD CONSTRAINT bankbranches_default_pkey PRIMARY KEY (bank_id, bank_region);


--
-- Name: bankbranches_north bankbranches_north_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bankbranches_north
    ADD CONSTRAINT bankbranches_north_pkey PRIMARY KEY (bank_id, bank_region);


--
-- Name: bankbranches_south bankbranches_south_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bankbranches_south
    ADD CONSTRAINT bankbranches_south_pkey PRIMARY KEY (bank_id, bank_region);


--
-- Name: marketsurvey marketsurvey_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.marketsurvey
    ADD CONSTRAINT marketsurvey_pkey PRIMARY KEY (survey_id);


--
-- Name: user_information user_information_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_information
    ADD CONSTRAINT user_information_pkey PRIMARY KEY (user_id);


--
-- Name: account_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX account_index ON public.account_information USING btree (account_id) INCLUDE (balance);


--
-- Name: bankbranches_default_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.bankbranches_pkey ATTACH PARTITION public.bankbranches_default_pkey;


--
-- Name: bankbranches_north_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.bankbranches_pkey ATTACH PARTITION public.bankbranches_north_pkey;


--
-- Name: bankbranches_south_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.bankbranches_pkey ATTACH PARTITION public.bankbranches_south_pkey;


--
-- Name: account_credentials account_cred_tg; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER account_cred_tg AFTER UPDATE OF password ON public.account_credentials FOR EACH ROW EXECUTE FUNCTION public.account_cred_tg_fn();


--
-- Name: account_credentials account_credentials_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_credentials
    ADD CONSTRAINT account_credentials_account_id_fkey FOREIGN KEY (account_id) REFERENCES public.account_information(account_id);


--
-- Name: account_info_trans_history account_info_trans_history_trans_sourceid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_info_trans_history
    ADD CONSTRAINT account_info_trans_history_trans_sourceid_fkey FOREIGN KEY (trans_sourceid) REFERENCES public.account_information(account_id);


--
-- Name: account_info_trans_history account_info_trans_history_trans_targetid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_info_trans_history
    ADD CONSTRAINT account_info_trans_history_trans_targetid_fkey FOREIGN KEY (trans_targetid) REFERENCES public.account_information(account_id);


--
-- Name: account_information account_information_bank_id_bank_region_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_information
    ADD CONSTRAINT account_information_bank_id_bank_region_fkey FOREIGN KEY (bank_id, bank_region) REFERENCES public.bankbranches(bank_id, bank_region) MATCH FULL;


--
-- Name: account_information account_information_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_information
    ADD CONSTRAINT account_information_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.user_information(user_id);


--
-- Name: account_credentials account_cred_policy; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY account_cred_policy ON public.account_credentials USING ((CURRENT_USER = 'postgres'::name));


--
-- Name: account_credentials; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.account_credentials ENABLE ROW LEVEL SECURITY;

--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: pg_database_owner
--

GRANT ALL ON SCHEMA public TO chung;
GRANT ALL ON SCHEMA public TO abel;


--
-- Name: TABLE account_cred_his; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.account_cred_his TO chung;
GRANT ALL ON TABLE public.account_cred_his TO abel;


--
-- Name: SEQUENCE account_cred_his_his_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.account_cred_his_his_id_seq TO chung;
GRANT ALL ON SEQUENCE public.account_cred_his_his_id_seq TO abel;


--
-- Name: TABLE account_credentials; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.account_credentials TO chung;
GRANT ALL ON TABLE public.account_credentials TO abel;


--
-- Name: TABLE account_info_trans_history; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.account_info_trans_history TO chung;
GRANT ALL ON TABLE public.account_info_trans_history TO abel;


--
-- Name: SEQUENCE account_info_trans_history_trans_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.account_info_trans_history_trans_id_seq TO chung;
GRANT ALL ON SEQUENCE public.account_info_trans_history_trans_id_seq TO abel;


--
-- Name: TABLE account_information; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.account_information TO chung;
GRANT ALL ON TABLE public.account_information TO abel;


--
-- Name: SEQUENCE account_information_account_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.account_information_account_id_seq TO chung;
GRANT ALL ON SEQUENCE public.account_information_account_id_seq TO abel;


--
-- Name: TABLE bankbranches; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.bankbranches TO chung;
GRANT ALL ON TABLE public.bankbranches TO abel;


--
-- Name: TABLE user_information; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.user_information TO chung;
GRANT ALL ON TABLE public.user_information TO abel;


--
-- Name: TABLE account_view; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.account_view TO chung;
GRANT ALL ON TABLE public.account_view TO abel;


--
-- Name: SEQUENCE bankbranches_bank_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.bankbranches_bank_id_seq TO chung;
GRANT ALL ON SEQUENCE public.bankbranches_bank_id_seq TO abel;


--
-- Name: TABLE bankbranches_default; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.bankbranches_default TO chung;
GRANT ALL ON TABLE public.bankbranches_default TO abel;


--
-- Name: TABLE bankbranches_north; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.bankbranches_north TO chung;
GRANT ALL ON TABLE public.bankbranches_north TO abel;


--
-- Name: TABLE bankbranches_south; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.bankbranches_south TO chung;
GRANT ALL ON TABLE public.bankbranches_south TO abel;


--
-- Name: TABLE marketsurvey; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.marketsurvey TO chung;
GRANT ALL ON TABLE public.marketsurvey TO abel;


--
-- Name: SEQUENCE marketsurvey_survey_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.marketsurvey_survey_id_seq TO chung;
GRANT ALL ON SEQUENCE public.marketsurvey_survey_id_seq TO abel;


--
-- Name: SEQUENCE user_information_user_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.user_information_user_id_seq TO chung;
GRANT ALL ON SEQUENCE public.user_information_user_id_seq TO abel;


--
-- PostgreSQL database dump complete
--

--
-- PostgreSQL database cluster dump complete
--

