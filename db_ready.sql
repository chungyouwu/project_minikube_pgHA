--
-- PostgreSQL database cluster dump
--

SET default_transaction_read_only = off;

SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;

--
-- Roles
--

CREATE ROLE chung;
ALTER ROLE chung WITH NOSUPERUSER INHERIT NOCREATEROLE NOCREATEDB LOGIN NOREPLICATION NOBYPASSRLS PASSWORD 'SCRAM-SHA-256$4096:PKvx62GjZHma8qmpmobEOg==$kYwmP36c5DLb3LxEkFfEPFJc1U72xNtZk74g05gD6h8=:HbKjTNqvoMVyBDtRy9d+NLF77fyO8PDB/6mO1OOZ8pY=';
CREATE ROLE postgres;
ALTER ROLE postgres WITH SUPERUSER INHERIT CREATEROLE CREATEDB LOGIN REPLICATION BYPASSRLS PASSWORD 'SCRAM-SHA-256$4096:LRBvds5uWXp9PET6hZX4cQ==$oKkFwfDGuU6G2mOw0eCCqXtddm7MkWKL0liEOI6Cph4=:Fv6YXZTmI95c40ZyIDpNqC4gMMb/yLjDZxic1e/LnW0=';
CREATE ROLE replication;
ALTER ROLE replication WITH NOSUPERUSER INHERIT NOCREATEROLE NOCREATEDB LOGIN REPLICATION NOBYPASSRLS PASSWORD 'SCRAM-SHA-256$4096:G1mYSKGKUwLr19VF4cD8dg==$Vz8mhtAwge7uJ5Bw7nZAyNZQhS+M+zdIK3aT4H/dxHA=:JNe5bCtRB6Cn9e0G8f77iFnP3QGLpo/MzuKv0dGs5fA=';

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
-- Dumped by pg_dump version 16.0

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
-- Dumped by pg_dump version 16.0

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
INSERT INTO account_info_his(old_password, new_password) 
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
    insert into transaction_history(trans_sourceid,trans_amount,trans_targetid, trans_reason, trans_method) 
    values(m_from,amount,m_to, reason, method);
        
  else 
    raise exception 'One of the accounts does not exist';
    
  end if;
END$$;


ALTER PROCEDURE public.transfer_funds(IN m_from integer, IN m_to integer, IN amount numeric, IN reason character varying, IN method public.payby) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: account_credentials; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.account_credentials (
    account_id integer,
    password character varying(50) NOT NULL
);


ALTER TABLE public.account_credentials OWNER TO postgres;

--
-- Name: account_info_his; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.account_info_his (
    his_id integer NOT NULL,
    his_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    old_password character varying(50),
    new_password character varying(50)
);


ALTER TABLE public.account_info_his OWNER TO postgres;

--
-- Name: account_info_his_his_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.account_info_his_his_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.account_info_his_his_id_seq OWNER TO postgres;

--
-- Name: account_info_his_his_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.account_info_his_his_id_seq OWNED BY public.account_info_his.his_id;


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
-- Name: transaction_history; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.transaction_history (
    trans_id integer NOT NULL,
    trans_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    trans_sourceid integer NOT NULL,
    trans_amount numeric(15,2) NOT NULL,
    trans_targetid integer NOT NULL,
    trans_reason character varying(30),
    trans_method public.payby
);


ALTER TABLE public.transaction_history OWNER TO postgres;

--
-- Name: transaction_history_trans_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.transaction_history_trans_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.transaction_history_trans_id_seq OWNER TO postgres;

--
-- Name: transaction_history_trans_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.transaction_history_trans_id_seq OWNED BY public.transaction_history.trans_id;


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
-- Name: account_info_his his_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_info_his ALTER COLUMN his_id SET DEFAULT nextval('public.account_info_his_his_id_seq'::regclass);


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
-- Name: transaction_history trans_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transaction_history ALTER COLUMN trans_id SET DEFAULT nextval('public.transaction_history_trans_id_seq'::regclass);


--
-- Name: user_information user_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_information ALTER COLUMN user_id SET DEFAULT nextval('public.user_information_user_id_seq'::regclass);


--
-- Data for Name: account_credentials; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.account_credentials (account_id, password) FROM stdin;
1	9613
2	5074
3	3551
4	1951
5	7047
6	7468
7	7148
8	5689
9	5823
10	3536
11	5762
12	2777
13	4577
14	3815
15	1186
16	7582
17	1475
18	3481
19	3444
20	5060
21	6983
22	6678
23	8122
24	6411
25	7065
26	5060
27	7852
28	5950
29	6890
30	1223
31	0982
32	7569
33	8020
34	0648
35	2565
36	2197
37	7385
38	0029
39	3082
40	3911
41	7613
42	6482
43	2410
44	2953
45	7754
46	3379
47	3270
48	9259
49	6425
50	3759
51	8991
52	4337
53	6854
54	1742
55	5258
56	5622
57	8946
58	7484
59	6783
60	7483
61	6985
62	6668
63	1017
64	1193
65	6219
66	2593
67	5757
68	8574
69	1734
70	9324
71	1018
72	6341
73	9338
74	7158
75	0329
76	9702
77	1142
78	8895
79	0236
80	7921
81	5315
82	2307
83	1047
84	2558
85	5777
86	0182
87	7916
88	9652
89	1246
90	7948
91	7718
92	9585
93	6550
94	1475
95	7199
96	4979
97	7453
98	4472
99	2948
100	2643
101	4335
102	0218
103	2303
104	6489
105	6153
106	6797
107	6556
108	7034
109	0127
110	7746
111	1528
112	2681
113	3891
114	7991
115	8999
116	9707
117	9719
118	6197
119	6578
120	7102
121	7985
122	2300
123	5452
124	6325
125	1003
126	3242
127	3452
128	4517
129	9362
130	2982
131	1409
132	9154
133	1932
134	8102
135	3263
136	2200
137	8830
138	9254
139	7496
140	3541
141	7779
142	5597
143	5518
144	3120
145	8441
146	9596
147	6216
148	0418
149	3352
150	2830
151	6017
152	2269
153	2350
154	3535
155	4952
156	4277
157	9250
158	2507
159	1167
160	1961
161	2366
162	9309
163	3574
164	8817
165	0288
166	1304
167	0634
168	3835
169	2958
170	0405
171	9187
172	9347
173	9196
174	8353
175	5376
176	3523
177	6966
178	6849
179	3484
180	9077
181	2942
182	7561
183	3626
184	4293
185	9535
186	6093
187	0264
188	2542
189	6232
190	0486
191	7315
192	9740
193	4162
194	4907
195	0293
196	6906
197	2535
198	6403
199	4719
200	4948
201	5715
202	6150
203	2682
204	0358
205	3853
206	3963
207	7101
208	2890
209	9277
210	2229
211	3968
212	0522
213	3209
214	2640
215	5009
216	3071
217	7996
218	1880
219	8619
220	6995
221	6797
222	0318
223	0425
224	1485
225	6055
226	6256
227	8719
228	8050
229	0054
230	7322
231	3314
232	6135
233	5145
234	9536
235	9522
236	9515
237	4367
238	0259
239	6307
240	8417
241	1760
242	6088
243	2199
244	9868
245	6783
246	0065
247	6701
248	5954
249	4594
250	9675
251	9169
252	4413
253	6055
254	1368
255	9899
256	2053
257	7573
258	7912
259	3110
260	0083
261	2403
262	5156
263	0688
264	9693
265	3315
266	6874
267	3728
268	4514
269	8243
270	1279
271	9574
272	7636
273	3073
274	2911
275	9024
276	7746
277	7450
278	1905
279	6662
280	4319
281	7597
282	8653
283	9614
284	1184
285	8815
286	8292
287	4458
288	5322
289	5383
290	7980
291	3832
292	4064
293	0816
294	8581
295	9569
296	6408
297	3128
298	6065
299	1431
300	0085
301	1459
302	4774
303	9720
304	3398
305	6038
306	3731
307	5937
308	2902
309	0038
310	9679
311	1723
312	3776
313	4914
314	4068
315	8474
316	2644
317	6905
318	7844
319	1052
320	0052
321	5179
322	6794
323	3239
324	2078
325	2044
326	9798
327	1784
328	3031
329	7447
330	4080
331	2443
332	7328
333	2017
334	7185
335	2811
336	4897
337	4588
338	3070
339	1286
340	6381
341	2116
342	6942
343	7498
344	7941
345	7722
346	7517
347	7093
348	5492
349	4751
350	3733
351	4828
352	0923
353	6294
354	3682
355	6841
356	8367
357	7725
358	5270
359	6367
360	5858
361	4462
362	7041
363	2016
364	0181
365	5815
366	6770
367	8478
368	3215
369	1785
370	0593
371	3548
372	9918
373	9742
374	8184
375	0297
376	5314
377	4486
378	2839
379	2234
380	2845
381	7506
382	3502
383	9772
384	1804
385	5604
386	2939
387	4536
388	6220
389	1851
390	8086
391	4540
392	5567
393	3906
394	9816
395	4036
396	8117
397	6503
398	1136
399	4405
400	3400
401	2974
402	9835
403	1445
404	1200
405	4971
406	3495
407	0147
408	2078
409	0726
410	1486
411	4511
412	6459
413	8689
414	4734
415	0269
416	9151
417	5431
418	5819
419	7388
420	0839
421	8218
422	1724
423	8199
424	8858
425	4222
426	7023
427	5951
428	1233
429	7991
430	0775
431	5883
432	0628
433	6791
434	6178
435	2477
436	7439
437	4822
438	7820
439	3852
440	3233
441	2626
442	3239
443	0926
444	1749
445	5869
446	0491
447	0507
448	4551
449	6215
450	1031
451	4121
452	6222
453	2600
454	4373
455	7516
456	8256
457	4702
458	0678
459	1628
460	4799
461	2453
462	5432
463	1206
464	5151
465	7836
466	7206
467	9622
468	3557
469	0985
470	4860
471	3139
472	3899
473	0820
474	6568
475	3802
476	6702
477	8326
478	3248
479	0314
480	7282
481	0119
482	6408
483	7032
484	5996
485	1409
486	4557
487	3331
488	6864
489	5305
490	5980
491	4154
492	2427
493	3897
494	8588
495	4462
496	1331
497	2317
498	4015
499	9550
500	4507
501	2072
502	5611
503	1860
504	7367
505	9928
506	1561
507	7142
508	4638
509	8802
510	8401
511	6152
512	5711
513	6163
514	9357
515	1962
516	1236
517	2588
518	1280
519	3536
520	2411
521	3289
522	2365
523	7997
524	4294
525	2811
526	9724
527	7369
528	9003
529	8462
530	2938
531	1014
532	9530
533	8504
534	1545
535	7578
536	3594
537	3336
538	8629
539	6132
540	9561
541	7349
542	0256
543	3127
544	1292
545	4528
546	9284
547	6679
548	0752
549	2691
550	1764
551	5026
552	7875
553	5314
554	2803
555	9137
556	5452
557	8150
558	5696
559	2072
560	2564
561	9827
562	0149
563	5116
564	2490
565	7048
566	0160
567	6540
568	6278
569	8831
570	2293
571	6153
572	9431
573	1212
574	9355
575	6411
576	4527
577	1899
578	5457
579	7062
580	9513
581	4564
582	3988
583	4423
584	0540
585	4023
586	9462
587	3424
588	9967
589	3200
590	5220
591	5827
592	7714
593	8085
594	1517
595	4927
596	9683
597	8625
598	5043
599	5105
600	7160
601	8107
602	5354
603	5655
604	7132
605	3526
606	5069
607	7090
608	9143
609	7852
610	1963
611	7389
612	4712
613	1254
614	2621
615	0506
616	4527
617	6900
618	2968
619	8333
620	1115
621	0722
622	8369
623	8333
624	1787
625	9521
626	3962
627	1347
628	5428
629	9866
630	4120
631	4639
632	3420
633	8997
634	2366
635	0198
636	2694
637	3478
638	0780
639	6958
640	9773
641	4190
642	6475
643	5389
644	2932
645	0398
646	0087
647	4253
648	9510
649	5352
650	0226
651	9993
652	9150
653	9651
654	4715
655	2297
656	5681
657	0936
658	1300
659	2047
660	7620
661	8504
662	8798
663	7822
664	6180
665	2624
666	7411
667	1181
668	4153
669	4322
670	6249
671	5175
672	6833
673	2547
674	2879
675	7638
676	5230
677	8914
678	9637
679	8787
680	8581
681	2308
682	1418
683	8600
684	5691
685	9826
686	9565
687	0830
688	8702
689	2988
690	8427
691	4044
692	1625
693	6295
694	6738
695	3517
696	3321
697	7511
698	9023
699	9688
700	1644
701	9974
702	1844
703	3558
704	5382
705	6349
706	9378
707	6971
708	3727
709	7638
710	1965
711	2687
712	3890
713	0237
714	3952
715	4260
716	7975
717	1631
718	0351
719	8011
720	0984
721	4232
722	1336
723	6772
724	8534
725	9729
726	3043
727	6112
728	7443
729	4620
730	7253
731	9850
732	2586
733	8174
734	3746
735	1669
736	0847
737	6561
738	1262
739	0515
740	2046
741	8734
742	3042
743	7585
744	0841
745	1898
746	9788
747	2464
748	2647
749	0871
750	5914
751	6065
752	9431
753	5167
754	7619
755	5973
756	7352
757	2304
758	7838
759	1312
760	3711
761	8048
762	3940
763	9909
764	9182
765	4905
766	3959
767	4008
768	3420
769	1893
770	7173
771	2424
772	7821
773	5291
774	5555
775	0655
776	8439
777	3231
778	0369
779	9861
780	1144
781	5522
782	8207
783	5394
784	8853
785	1948
786	3642
787	0848
788	2090
789	3964
790	4239
791	1927
792	6363
793	7621
794	4854
795	4109
796	2477
797	5979
798	1442
799	9865
800	8223
801	1968
802	9317
803	4478
804	8283
805	0025
806	6637
807	8235
808	1382
809	0141
810	3281
811	6317
812	2639
813	8048
814	2144
815	9455
816	5658
817	3717
818	9558
819	6413
820	4771
821	8865
822	4306
823	1546
824	8788
825	6558
826	8264
827	1253
828	6210
829	8959
830	1337
831	2870
832	4959
833	5966
834	0970
835	2046
836	2276
837	2763
838	9294
839	1765
840	7090
841	1265
842	7479
843	5333
844	8780
845	0916
846	8826
847	2091
848	3561
849	0836
850	5303
851	1352
852	8543
853	8724
854	2878
855	9493
856	7868
857	0237
858	8135
859	0137
860	0415
861	8199
862	6025
863	2311
864	0236
865	4515
866	4540
867	1488
868	0707
869	9021
870	1367
871	2534
872	3517
873	4410
874	7948
875	7335
876	7427
877	0514
878	9650
879	2229
880	0963
881	5320
882	4627
883	0642
884	8250
885	3524
886	4906
887	1597
888	8524
889	4769
890	3337
891	0890
892	1628
893	8821
894	2636
895	1858
896	3513
897	2419
898	3275
899	9154
900	4968
901	3107
902	7012
903	2558
904	9420
905	7626
906	1254
907	2137
908	0282
909	1953
910	6493
911	5403
912	6169
913	9457
914	3592
915	3721
916	7840
917	4412
918	8549
919	3059
920	6507
921	2105
922	3414
923	7405
924	0660
925	3419
926	9468
927	0762
928	6323
929	0715
930	1120
931	1492
932	1238
933	4801
934	0260
935	9774
936	8157
937	4087
938	4937
939	4675
940	5178
941	5094
942	1358
943	9805
944	9601
945	4322
946	6748
947	1105
948	7022
949	0152
950	8888
951	2242
952	2069
953	5300
954	0868
955	5645
956	6431
957	6669
958	9954
959	9030
960	1557
961	4462
962	2687
963	2968
964	1529
965	2110
966	8266
967	2327
968	6163
969	6142
970	3390
971	9394
972	7121
973	9241
974	0157
975	4625
976	8467
977	8817
978	8427
979	2167
980	1988
981	7052
982	5610
983	6660
984	1190
985	6143
986	8434
987	2808
988	9563
989	9570
990	3562
991	2160
992	2551
993	8888
994	9092
995	5059
996	8292
997	2219
998	5830
999	2339
1000	9840
\.


--
-- Data for Name: account_info_his; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.account_info_his (his_id, his_time, old_password, new_password) FROM stdin;
\.


--
-- Data for Name: account_information; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.account_information (account_id, user_id, bank_id, bank_region, balance, opendate) FROM stdin;
1	1	17	south	1937.67	2023-08-06
2	2	8	north	438.14	2024-05-19
3	3	7	north	8572.52	2024-03-28
4	4	14	south	8298.57	2023-09-10
5	5	7	north	5041.94	2023-11-27
6	6	10	north	4052.51	2024-06-10
7	7	11	south	5534.22	2024-01-09
8	8	16	south	1911.55	2023-10-01
9	9	16	south	4077.01	2023-08-20
10	10	3	north	5871.55	2024-02-25
11	11	7	north	4782.86	2023-10-21
12	12	15	south	8241.91	2024-02-09
13	13	11	south	3184.22	2024-03-23
14	14	6	north	2028.14	2023-11-17
15	15	3	north	249.73	2023-09-03
16	16	20	south	7435.91	2024-02-21
17	17	12	south	787.05	2023-09-23
18	18	13	south	9012.41	2024-02-29
19	19	9	north	9039.68	2024-05-11
20	20	15	south	574.21	2023-08-16
21	21	5	north	8762.79	2023-12-20
22	22	15	south	1664.26	2024-02-26
23	23	13	south	283.35	2023-10-17
24	24	2	north	4450.47	2024-07-16
25	25	4	north	8673.22	2024-01-29
26	26	11	south	102.87	2024-01-14
27	27	18	south	1811.45	2024-06-20
28	28	13	south	5241.66	2024-03-08
29	29	18	south	8640.74	2023-08-23
30	30	4	north	4755.95	2024-06-22
31	31	19	south	8368.42	2024-01-31
32	32	10	north	3036.45	2024-02-15
33	33	4	north	4139.17	2024-04-02
34	34	10	north	7651.21	2023-11-28
35	35	8	north	116.44	2023-12-04
36	36	12	south	5783.89	2023-09-13
37	37	19	south	9909.33	2023-11-17
38	38	8	north	6969.26	2024-02-10
39	39	2	north	9197.88	2024-07-13
40	40	12	south	8116.24	2023-12-21
41	41	5	north	5808.75	2023-12-13
42	42	17	south	5628.34	2024-07-21
43	43	16	south	9829.76	2023-10-05
44	44	17	south	7927.04	2024-06-11
45	45	1	north	2263.81	2024-05-25
46	46	17	south	4583.40	2024-02-20
47	47	10	north	8326.22	2023-10-13
48	48	20	south	5732.57	2023-12-28
49	49	11	south	629.33	2024-02-05
50	50	15	south	8940.36	2023-09-02
51	51	13	south	1038.31	2023-09-11
52	52	5	north	2723.58	2024-03-01
53	53	9	north	4297.53	2023-08-24
54	54	15	south	8441.42	2023-11-09
55	55	5	north	9517.62	2024-03-27
56	56	9	north	5084.80	2023-12-10
57	57	6	north	2169.24	2024-05-17
58	58	20	south	1592.33	2023-10-15
59	59	6	north	4277.53	2023-10-07
60	60	6	north	5346.42	2024-01-12
61	61	18	south	6934.25	2023-11-20
62	62	3	north	7836.66	2024-05-27
63	63	9	north	8500.53	2023-10-26
64	64	15	south	6898.24	2024-04-19
65	65	11	south	1024.87	2024-02-25
66	66	8	north	2290.55	2024-06-22
67	67	5	north	5672.13	2024-06-30
68	68	15	south	2215.28	2023-11-28
69	69	10	north	9068.62	2024-03-25
70	70	15	south	9667.57	2023-09-26
71	71	5	north	7666.67	2024-07-09
72	72	6	north	7496.92	2023-07-26
73	73	6	north	9237.04	2024-02-09
74	74	3	north	7042.17	2024-03-28
75	75	3	north	3848.64	2023-12-18
76	76	8	north	6860.80	2023-09-21
77	77	19	south	8124.86	2024-01-27
78	78	4	north	5825.03	2024-02-08
79	79	5	north	6093.01	2024-03-08
80	80	12	south	6167.11	2024-06-25
81	81	16	south	6268.54	2024-04-27
82	82	4	north	7194.59	2024-03-27
83	83	5	north	7055.66	2023-10-09
84	84	18	south	5774.48	2023-10-06
85	85	13	south	5455.28	2024-07-13
86	86	16	south	3941.19	2024-02-05
87	87	18	south	7641.21	2023-12-22
88	88	15	south	523.55	2024-04-13
89	89	8	north	6195.26	2024-07-18
90	90	17	south	9239.45	2023-09-01
91	91	18	south	806.99	2024-03-25
92	92	12	south	2875.29	2023-08-10
93	93	12	south	8619.06	2023-09-15
94	94	15	south	6719.79	2023-08-09
95	95	16	south	6010.67	2023-09-30
96	96	2	north	1577.29	2024-01-25
97	97	11	south	7015.91	2023-09-14
98	98	1	north	8973.41	2023-11-03
99	99	18	south	8327.40	2024-06-11
100	100	12	south	5686.41	2024-02-05
101	101	1	north	943.94	2023-10-10
102	102	3	north	5704.87	2024-02-12
103	103	6	north	6226.46	2024-05-22
104	104	3	north	9198.91	2024-04-28
105	105	8	north	987.58	2024-05-27
106	106	4	north	8984.77	2024-07-13
107	107	19	south	2592.11	2024-01-19
108	108	5	north	1703.55	2023-11-28
109	109	6	north	7853.53	2024-04-02
110	110	18	south	4610.56	2024-03-25
111	111	9	north	7870.94	2024-05-14
112	112	13	south	3867.87	2023-10-08
113	113	10	north	6066.91	2024-05-05
114	114	11	south	8696.90	2024-02-06
115	115	16	south	7403.10	2023-10-20
116	116	7	north	8169.02	2023-11-28
117	117	19	south	1338.33	2024-01-29
118	118	16	south	8504.48	2024-06-27
119	119	17	south	1064.94	2024-03-10
120	120	17	south	6244.06	2023-09-01
121	121	20	south	1775.35	2024-04-27
122	122	16	south	1717.60	2024-06-27
123	123	16	south	3444.03	2023-09-06
124	124	5	north	4669.77	2024-01-21
125	125	4	north	2322.49	2024-05-09
126	126	3	north	3315.27	2024-05-22
127	127	6	north	8641.60	2023-11-06
128	128	6	north	8196.40	2024-03-12
129	129	14	south	8621.41	2023-08-18
130	130	14	south	9240.83	2023-09-05
131	131	14	south	5494.52	2024-05-16
132	132	8	north	8713.06	2023-10-08
133	133	2	north	5672.43	2024-07-17
134	134	16	south	9378.94	2023-09-13
135	135	19	south	40.23	2024-04-08
136	136	14	south	5771.80	2024-06-18
137	137	7	north	1335.17	2024-04-12
138	138	14	south	7152.05	2023-11-18
139	139	20	south	6454.31	2023-08-06
140	140	3	north	7241.43	2023-08-03
141	141	18	south	807.12	2023-08-03
142	142	4	north	2184.88	2024-05-16
143	143	14	south	2883.81	2023-09-03
144	144	15	south	979.75	2023-10-04
145	145	6	north	1360.07	2023-09-30
146	146	6	north	6340.33	2024-02-27
147	147	17	south	3428.69	2023-10-05
148	148	20	south	151.74	2023-10-04
149	149	14	south	9466.60	2024-06-02
150	150	9	north	2633.86	2024-06-13
151	151	15	south	5892.54	2023-08-03
152	152	15	south	958.17	2023-11-26
153	153	10	north	1229.85	2023-08-23
154	154	7	north	6923.10	2024-06-19
155	155	10	north	2213.41	2023-08-22
156	156	17	south	914.96	2024-07-11
157	157	14	south	5812.74	2024-03-18
158	158	8	north	5158.85	2023-09-09
159	159	16	south	3482.50	2023-07-28
160	160	13	south	7144.87	2023-09-18
161	161	4	north	8152.70	2024-01-01
162	162	4	north	5896.48	2024-02-25
163	163	19	south	4732.58	2024-02-20
164	164	2	north	9676.99	2023-12-20
165	165	10	north	544.92	2024-03-29
166	166	10	north	1717.92	2023-10-10
167	167	15	south	9366.60	2023-12-22
168	168	7	north	5059.38	2024-01-24
169	169	12	south	3208.02	2024-02-13
170	170	2	north	7707.05	2024-07-21
171	171	5	north	6659.88	2024-05-13
172	172	12	south	3677.78	2024-06-07
173	173	9	north	7851.18	2023-10-15
174	174	11	south	7437.47	2023-09-28
175	175	17	south	6187.40	2024-06-18
176	176	1	north	4988.05	2023-12-04
177	177	19	south	6564.98	2023-11-09
178	178	13	south	6793.62	2024-03-23
179	179	8	north	5396.33	2024-02-12
180	180	11	south	6866.89	2023-12-04
181	181	17	south	3673.06	2024-05-14
182	182	10	north	9787.57	2024-04-30
183	183	4	north	7327.00	2024-06-06
184	184	8	north	9682.24	2023-08-04
185	185	4	north	8492.17	2024-02-01
186	186	6	north	7443.73	2023-11-29
187	187	14	south	3370.15	2023-08-23
188	188	19	south	163.64	2023-10-16
189	189	3	north	6289.89	2024-07-12
190	190	1	north	3444.51	2024-07-19
191	191	17	south	3497.24	2023-09-18
192	192	8	north	8538.12	2024-07-02
193	193	13	south	1319.73	2024-05-03
194	194	5	north	649.79	2023-11-12
195	195	1	north	6871.40	2024-02-19
196	196	10	north	7005.99	2024-05-28
197	197	9	north	4175.02	2023-12-15
198	198	15	south	5706.02	2023-12-28
199	199	7	north	4204.03	2023-08-06
200	200	5	north	1273.49	2023-08-25
201	201	10	north	9456.30	2023-10-23
202	202	14	south	2831.81	2023-12-11
203	203	1	north	1580.05	2023-07-28
204	204	2	north	1322.46	2024-05-30
205	205	4	north	8472.10	2024-03-23
206	206	8	north	1333.34	2023-12-25
207	207	12	south	9878.22	2024-06-20
208	208	19	south	2537.27	2024-02-01
209	209	4	north	2736.59	2023-08-16
210	210	10	north	6421.76	2023-09-20
211	211	4	north	8808.22	2024-02-29
212	212	15	south	7686.01	2024-03-31
213	213	6	north	6494.07	2024-06-23
214	214	8	north	9440.10	2023-10-28
215	215	13	south	1668.60	2024-03-01
216	216	8	north	9687.27	2023-10-18
217	217	4	north	6594.15	2024-03-22
218	218	15	south	6642.14	2024-05-05
219	219	15	south	1736.55	2023-08-31
220	220	6	north	2418.24	2024-02-12
221	221	5	north	9429.24	2024-03-28
222	222	19	south	4602.52	2024-03-14
223	223	4	north	8230.54	2023-08-21
224	224	2	north	4728.78	2023-10-13
225	225	6	north	1521.17	2023-10-07
226	226	4	north	3969.73	2023-11-02
227	227	5	north	809.07	2024-05-19
228	228	14	south	3973.40	2023-11-18
229	229	13	south	7551.64	2023-09-27
230	230	11	south	7392.18	2024-01-10
231	231	7	north	3144.72	2024-05-01
232	232	16	south	1467.90	2024-07-08
233	233	1	north	9599.41	2023-09-28
234	234	17	south	4011.07	2024-01-24
235	235	12	south	4730.73	2023-08-05
236	236	11	south	1918.23	2023-11-10
237	237	19	south	2699.62	2023-09-24
238	238	17	south	1960.63	2024-02-10
239	239	19	south	8926.43	2024-07-10
240	240	11	south	3703.64	2023-10-21
241	241	13	south	5991.93	2024-03-23
242	242	16	south	3941.42	2023-12-19
243	243	15	south	8289.17	2023-09-06
244	244	19	south	645.74	2024-03-22
245	245	1	north	9591.59	2023-11-18
246	246	3	north	3545.98	2023-08-27
247	247	16	south	1181.10	2024-04-27
248	248	13	south	7210.22	2023-12-30
249	249	11	south	7657.47	2024-07-21
250	250	2	north	9818.16	2024-03-15
251	251	10	north	9367.98	2024-03-26
252	252	4	north	3690.94	2024-07-22
253	253	9	north	2596.83	2023-11-12
254	254	13	south	3793.21	2024-01-25
255	255	18	south	4197.97	2023-08-28
256	256	17	south	1509.45	2024-07-20
257	257	17	south	9088.47	2024-05-22
258	258	17	south	8942.88	2024-05-01
259	259	7	north	8291.03	2024-02-03
260	260	14	south	9868.14	2023-12-14
261	261	2	north	2935.20	2024-05-10
262	262	4	north	3797.81	2024-03-14
263	263	15	south	5675.78	2023-12-07
264	264	10	north	802.05	2024-01-27
265	265	18	south	7282.39	2023-09-16
266	266	18	south	6279.70	2023-10-01
267	267	3	north	5752.16	2024-06-24
268	268	19	south	774.31	2024-01-10
269	269	13	south	6366.35	2023-10-08
270	270	20	south	9511.77	2024-07-11
271	271	4	north	5929.52	2024-02-10
272	272	3	north	3790.86	2023-10-11
273	273	8	north	7826.39	2024-06-20
274	274	13	south	274.58	2024-05-20
275	275	6	north	6661.03	2024-02-08
276	276	7	north	9974.96	2024-07-07
277	277	14	south	463.59	2023-12-28
278	278	11	south	8384.88	2023-08-10
279	279	12	south	81.21	2024-06-05
280	280	3	north	8278.38	2024-04-07
281	281	12	south	3272.96	2023-10-15
282	282	11	south	4227.12	2024-03-29
283	283	13	south	7911.87	2023-07-27
284	284	17	south	4089.33	2023-08-24
285	285	13	south	3089.64	2024-04-28
286	286	8	north	2216.79	2024-04-03
287	287	2	north	6968.63	2024-03-01
288	288	15	south	8447.76	2024-01-13
289	289	10	north	8362.19	2023-11-17
290	290	7	north	4132.77	2023-11-17
291	291	18	south	6223.57	2023-12-08
292	292	6	north	5617.77	2023-10-27
293	293	3	north	8331.21	2024-04-28
294	294	18	south	1195.47	2023-10-25
295	295	14	south	2888.72	2023-12-25
296	296	7	north	4485.48	2023-11-26
297	297	20	south	2296.48	2023-09-23
298	298	9	north	5109.46	2024-05-01
299	299	4	north	8085.17	2024-01-18
300	300	6	north	7077.32	2024-04-29
301	301	7	north	2749.66	2023-08-13
302	302	15	south	6632.68	2024-07-02
303	303	17	south	8044.57	2024-06-21
304	304	1	north	2650.73	2024-03-02
305	305	20	south	6694.59	2024-03-20
306	306	2	north	3167.74	2024-02-25
307	307	4	north	5321.94	2024-05-31
308	308	5	north	937.35	2024-06-12
309	309	7	north	9985.31	2024-04-26
310	310	3	north	4349.72	2024-05-01
311	311	2	north	7378.32	2023-08-28
312	312	19	south	8282.82	2024-03-23
313	313	5	north	5490.36	2023-10-28
314	314	14	south	9547.98	2024-03-04
315	315	2	north	7293.43	2024-01-11
316	316	1	north	1768.28	2023-09-08
317	317	19	south	589.73	2024-02-19
318	318	3	north	9116.38	2023-12-27
319	319	20	south	306.34	2023-09-26
320	320	3	north	2999.63	2023-11-16
321	321	15	south	8770.33	2023-09-15
322	322	14	south	4345.56	2023-10-03
323	323	16	south	1478.45	2023-11-09
324	324	1	north	5896.47	2024-03-21
325	325	16	south	5735.15	2023-10-17
326	326	2	north	3600.83	2023-08-10
327	327	18	south	8065.95	2024-07-02
328	328	18	south	6887.09	2023-08-17
329	329	15	south	9516.94	2023-10-06
330	330	14	south	1543.95	2024-05-29
331	331	3	north	1014.06	2024-04-08
332	332	2	north	9685.04	2023-10-07
333	333	4	north	2210.54	2024-03-27
334	334	2	north	1019.93	2023-12-29
335	335	16	south	8720.42	2023-11-08
336	336	19	south	8894.42	2023-12-09
337	337	16	south	1469.08	2023-08-20
338	338	5	north	8215.09	2023-09-09
339	339	19	south	238.83	2023-09-22
340	340	11	south	7637.78	2023-09-27
341	341	13	south	2632.84	2024-03-28
342	342	1	north	6491.16	2023-12-24
343	343	3	north	9125.16	2024-02-23
344	344	20	south	1208.18	2024-04-08
345	345	3	north	7845.27	2024-02-13
346	346	6	north	9752.09	2024-04-24
347	347	17	south	2101.45	2024-03-05
348	348	10	north	9.51	2024-06-15
349	349	12	south	9811.12	2023-09-12
350	350	20	south	8593.67	2024-04-08
351	351	5	north	6615.71	2023-12-13
352	352	18	south	4455.18	2023-09-12
353	353	19	south	4231.01	2024-02-11
354	354	11	south	4368.02	2024-03-15
355	355	7	north	6380.34	2023-08-05
356	356	13	south	9887.82	2024-07-02
357	357	13	south	6267.35	2024-01-22
358	358	3	north	889.18	2024-06-28
359	359	8	north	3602.55	2024-04-08
360	360	13	south	1576.04	2024-06-04
361	361	5	north	2474.03	2023-12-03
362	362	15	south	435.59	2024-06-28
363	363	7	north	7105.14	2024-07-04
364	364	6	north	5151.60	2024-02-29
365	365	15	south	9533.32	2023-10-06
366	366	4	north	3108.16	2023-11-07
367	367	9	north	4292.83	2024-04-28
368	368	5	north	4852.17	2024-05-06
369	369	3	north	4593.45	2024-01-06
370	370	12	south	2361.37	2023-12-26
371	371	10	north	4905.50	2023-09-27
372	372	4	north	1262.49	2024-05-01
373	373	4	north	7254.07	2023-10-28
374	374	13	south	7382.63	2024-04-15
375	375	11	south	9080.15	2024-04-10
376	376	19	south	8576.00	2023-10-29
377	377	1	north	7828.95	2024-04-26
378	378	7	north	5894.02	2024-07-17
379	379	5	north	2467.22	2023-08-03
380	380	3	north	2711.53	2023-11-23
381	381	11	south	4197.25	2024-02-01
382	382	15	south	3164.95	2024-01-31
383	383	1	north	4450.02	2023-10-07
384	384	11	south	6865.99	2024-05-15
385	385	8	north	1333.58	2023-09-01
386	386	18	south	1761.79	2023-10-09
387	387	7	north	7222.28	2024-07-05
388	388	6	north	7025.70	2024-05-08
389	389	15	south	299.70	2024-04-23
390	390	4	north	9558.21	2023-12-04
391	391	18	south	7592.65	2024-05-18
392	392	3	north	1701.98	2023-09-02
393	393	19	south	559.15	2024-02-26
394	394	14	south	4850.19	2024-02-25
395	395	8	north	4002.56	2023-10-14
396	396	17	south	3432.57	2024-04-07
397	397	19	south	6890.85	2023-12-26
398	398	9	north	7793.97	2023-08-12
399	399	4	north	1150.45	2024-06-13
400	400	9	north	4991.81	2023-11-13
401	401	20	south	7818.19	2023-11-17
402	402	17	south	7454.06	2023-08-19
403	403	15	south	4540.15	2023-12-21
404	404	14	south	1332.62	2024-06-06
405	405	6	north	2807.54	2024-04-07
406	406	1	north	5748.21	2024-07-08
407	407	16	south	7636.71	2024-04-11
408	408	11	south	3491.78	2024-03-20
409	409	20	south	8408.04	2024-02-23
410	410	6	north	1315.99	2024-01-30
411	411	3	north	900.54	2023-10-31
412	412	9	north	11.33	2024-01-26
413	413	8	north	6125.85	2024-01-04
414	414	5	north	4190.21	2023-10-16
415	415	16	south	5262.87	2023-08-13
416	416	4	north	8285.98	2024-02-09
417	417	2	north	2999.46	2023-10-28
418	418	2	north	4326.48	2024-07-17
419	419	4	north	3838.87	2024-02-27
420	420	5	north	9192.49	2023-09-08
421	421	11	south	6564.08	2024-02-16
422	422	7	north	7280.66	2024-02-07
423	423	1	north	2327.06	2024-02-04
424	424	7	north	7038.89	2023-08-25
425	425	17	south	6730.91	2023-12-28
426	426	6	north	2994.86	2024-07-04
427	427	2	north	1794.17	2024-04-29
428	428	2	north	7376.43	2024-02-08
429	429	18	south	6432.63	2024-01-17
430	430	19	south	5518.77	2024-07-03
431	431	7	north	9256.75	2024-05-19
432	432	9	north	8279.29	2024-06-12
433	433	5	north	5644.23	2024-05-05
434	434	20	south	1117.36	2023-09-02
435	435	2	north	5155.55	2024-06-13
436	436	1	north	1923.42	2023-11-26
437	437	15	south	9233.76	2023-09-09
438	438	19	south	7716.20	2023-07-31
439	439	17	south	1223.68	2024-05-14
440	440	20	south	8215.22	2024-07-05
441	441	1	north	9786.21	2024-04-05
442	442	20	south	4044.14	2023-11-24
443	443	17	south	7558.74	2024-01-17
444	444	14	south	2350.69	2024-03-12
445	445	4	north	4213.56	2023-11-18
446	446	16	south	8939.23	2023-08-19
447	447	8	north	7006.75	2024-07-08
448	448	18	south	3171.63	2024-05-01
449	449	10	north	4478.70	2023-10-08
450	450	1	north	4036.17	2024-03-26
451	451	20	south	4380.60	2023-09-03
452	452	8	north	9980.69	2023-11-28
453	453	12	south	1770.76	2024-02-10
454	454	6	north	4210.30	2024-06-08
455	455	13	south	6847.07	2024-02-26
456	456	7	north	701.35	2024-04-08
457	457	10	north	6742.97	2023-10-09
458	458	8	north	3391.54	2023-10-05
459	459	19	south	9695.70	2024-05-21
460	460	8	north	8720.77	2024-02-06
461	461	3	north	5222.61	2024-05-28
462	462	11	south	6305.21	2024-02-28
463	463	6	north	1023.18	2023-11-24
464	464	14	south	203.99	2024-03-25
465	465	1	north	8190.81	2024-06-27
466	466	19	south	4836.82	2024-03-21
467	467	1	north	684.34	2023-11-23
468	468	5	north	8046.21	2023-09-17
469	469	18	south	3472.33	2024-02-18
470	470	18	south	6267.36	2024-01-20
471	471	16	south	6185.22	2024-04-27
472	472	13	south	6627.99	2023-12-05
473	473	18	south	3758.55	2024-03-19
474	474	14	south	7246.41	2024-07-15
475	475	14	south	6036.53	2024-02-18
476	476	9	north	5656.76	2023-11-21
477	477	7	north	6466.74	2023-09-25
478	478	5	north	8858.70	2023-11-01
479	479	17	south	5655.54	2024-06-28
480	480	5	north	8775.87	2023-08-02
481	481	13	south	7204.15	2023-11-09
482	482	16	south	9353.65	2024-06-14
483	483	3	north	5155.01	2023-10-14
484	484	4	north	9146.58	2024-04-08
485	485	10	north	2456.37	2024-04-26
486	486	5	north	9853.15	2023-12-20
487	487	20	south	560.86	2023-12-12
488	488	12	south	1199.70	2023-08-02
489	489	5	north	6880.22	2024-02-14
490	490	12	south	5412.91	2024-01-25
491	491	6	north	2146.92	2024-03-30
492	492	20	south	7740.92	2024-05-29
493	493	5	north	2762.41	2024-01-05
494	494	11	south	285.80	2023-11-18
495	495	11	south	959.13	2023-11-08
496	496	5	north	3689.25	2024-05-10
497	497	1	north	2869.87	2023-12-07
498	498	18	south	9067.21	2024-02-16
499	499	5	north	3369.57	2023-12-21
500	500	6	north	2980.78	2024-02-05
501	501	8	north	1912.92	2023-10-02
502	502	7	north	7978.98	2024-01-10
503	503	15	south	3765.16	2024-02-20
504	504	11	south	7055.02	2023-09-04
505	505	10	north	4344.36	2023-10-15
506	506	14	south	6269.27	2024-07-21
507	507	8	north	7631.23	2024-07-04
508	508	14	south	751.41	2023-09-04
509	509	8	north	2703.08	2023-10-07
510	510	16	south	707.52	2024-07-21
511	511	15	south	4782.20	2024-04-27
512	512	9	north	8953.31	2024-03-07
513	513	11	south	6259.50	2023-10-12
514	514	10	north	6067.15	2024-01-31
515	515	20	south	7570.24	2023-09-18
516	516	20	south	26.31	2023-11-08
517	517	19	south	2334.04	2024-06-25
518	518	3	north	8392.05	2023-09-26
519	519	1	north	8147.11	2024-02-01
520	520	20	south	4322.86	2024-05-01
521	521	18	south	5033.70	2023-10-26
522	522	7	north	8714.36	2023-12-17
523	523	19	south	8435.73	2024-05-19
524	524	15	south	1956.41	2024-02-20
525	525	11	south	5796.54	2023-10-18
526	526	9	north	8559.22	2023-12-29
527	527	12	south	599.19	2024-05-25
528	528	7	north	3575.84	2024-07-04
529	529	1	north	1420.31	2023-08-09
530	530	9	north	5165.95	2024-06-17
531	531	8	north	2964.26	2023-10-11
532	532	19	south	7985.76	2023-12-04
533	533	19	south	6496.50	2024-02-20
534	534	8	north	315.43	2023-10-27
535	535	2	north	7963.61	2024-01-02
536	536	19	south	3508.71	2024-05-20
537	537	8	north	8312.17	2024-02-06
538	538	17	south	9929.13	2024-05-11
539	539	14	south	7186.72	2023-08-20
540	540	14	south	8229.40	2024-01-02
541	541	8	north	6676.17	2024-01-09
542	542	17	south	2658.79	2023-08-03
543	543	5	north	338.13	2023-11-13
544	544	10	north	4785.14	2024-01-12
545	545	20	south	3136.97	2024-06-06
546	546	14	south	4385.06	2023-09-26
547	547	12	south	7574.96	2023-08-19
548	548	17	south	3982.57	2024-07-12
549	549	8	north	9587.30	2023-11-16
550	550	14	south	9262.03	2023-08-12
551	551	15	south	6056.85	2023-12-06
552	552	7	north	5845.77	2024-07-08
553	553	15	south	4323.19	2024-01-06
554	554	4	north	4791.55	2024-04-12
555	555	5	north	2986.52	2023-08-11
556	556	8	north	1749.42	2024-01-07
557	557	4	north	3106.28	2023-12-12
558	558	12	south	9389.43	2023-11-27
559	559	17	south	2133.42	2023-10-28
560	560	9	north	9595.03	2024-03-06
561	561	3	north	3327.30	2024-05-26
562	562	11	south	4199.84	2023-11-03
563	563	4	north	6151.35	2024-03-10
564	564	9	north	6596.20	2024-03-24
565	565	16	south	3668.75	2023-10-14
566	566	15	south	3263.16	2024-05-30
567	567	17	south	7386.56	2024-01-25
568	568	13	south	1720.34	2023-12-10
569	569	6	north	820.96	2024-06-02
570	570	6	north	6519.01	2023-09-03
571	571	7	north	5920.75	2023-07-27
572	572	9	north	1478.80	2023-08-19
573	573	8	north	6204.85	2023-09-08
574	574	8	north	2953.58	2024-02-08
575	575	13	south	7412.96	2023-08-30
576	576	19	south	1102.26	2024-06-08
577	577	3	north	2370.86	2023-12-02
578	578	17	south	709.94	2023-10-14
579	579	10	north	2887.70	2023-11-27
580	580	3	north	3469.10	2023-11-19
581	581	17	south	8367.12	2024-03-12
582	582	20	south	8207.25	2023-07-28
583	583	7	north	9545.57	2023-08-05
584	584	17	south	8237.87	2023-11-21
585	585	6	north	9759.31	2024-06-29
586	586	12	south	2254.21	2023-08-27
587	587	11	south	1867.23	2024-01-01
588	588	2	north	9846.77	2024-03-12
589	589	10	north	5442.81	2023-11-24
590	590	6	north	6461.41	2023-09-20
591	591	10	north	3940.68	2024-02-17
592	592	7	north	1993.07	2023-07-30
593	593	1	north	4448.71	2023-09-13
594	594	16	south	925.62	2023-10-15
595	595	19	south	9331.45	2023-09-24
596	596	14	south	3281.53	2023-09-08
597	597	16	south	7067.46	2023-09-29
598	598	7	north	6758.61	2024-07-15
599	599	4	north	4089.64	2024-03-26
600	600	1	north	6579.74	2024-03-09
601	601	15	south	653.95	2023-12-25
602	602	17	south	6047.76	2024-01-08
603	603	10	north	5542.31	2023-09-26
604	604	8	north	7849.76	2024-06-04
605	605	6	north	161.39	2024-01-31
606	606	19	south	8613.71	2023-09-21
607	607	7	north	532.82	2023-11-07
608	608	3	north	138.64	2024-03-17
609	609	16	south	3728.33	2024-03-18
610	610	12	south	5051.01	2024-02-21
611	611	2	north	4683.05	2024-05-22
612	612	16	south	5860.83	2024-04-21
613	613	11	south	2774.11	2024-03-16
614	614	7	north	8466.33	2023-09-09
615	615	1	north	4104.70	2023-09-04
616	616	2	north	3537.96	2023-11-22
617	617	12	south	2398.39	2024-05-23
618	618	1	north	9158.09	2023-10-21
619	619	1	north	5624.53	2024-07-22
620	620	16	south	8747.35	2024-03-13
621	621	3	north	1030.69	2023-09-18
622	622	3	north	1254.79	2024-04-24
623	623	4	north	8143.42	2023-08-13
624	624	3	north	2243.12	2024-02-01
625	625	4	north	3347.14	2023-12-20
626	626	14	south	7251.74	2024-03-31
627	627	14	south	7614.65	2024-01-04
628	628	19	south	9704.15	2024-05-03
629	629	8	north	5814.74	2024-07-13
630	630	18	south	8563.27	2024-01-13
631	631	6	north	7846.24	2024-07-21
632	632	18	south	1262.56	2024-04-09
633	633	15	south	4120.55	2023-08-20
634	634	9	north	7755.33	2023-12-14
635	635	13	south	5984.08	2024-06-08
636	636	3	north	4582.75	2023-10-23
637	637	14	south	7790.95	2024-04-18
638	638	16	south	2328.70	2023-12-24
639	639	4	north	6451.34	2024-06-10
640	640	19	south	9164.91	2023-10-24
641	641	11	south	8480.86	2024-04-19
642	642	19	south	1060.76	2023-09-26
643	643	8	north	3523.05	2023-09-02
644	644	13	south	7872.44	2024-04-22
645	645	1	north	3776.19	2024-04-13
646	646	5	north	1845.72	2024-06-05
647	647	3	north	4102.73	2023-07-27
648	648	6	north	8222.63	2024-02-22
649	649	14	south	5941.65	2024-07-16
650	650	6	north	8903.45	2023-11-08
651	651	13	south	2202.55	2023-08-18
652	652	19	south	4217.41	2023-08-07
653	653	5	north	3910.71	2024-07-14
654	654	5	north	9043.12	2023-11-14
655	655	1	north	2598.48	2023-08-19
656	656	11	south	6401.57	2024-02-27
657	657	14	south	7622.52	2024-04-02
658	658	17	south	3226.14	2023-12-25
659	659	8	north	2887.26	2023-11-30
660	660	19	south	3583.77	2023-08-11
661	661	10	north	1859.32	2023-11-05
662	662	9	north	9049.38	2023-12-30
663	663	4	north	2410.14	2023-10-05
664	664	6	north	7192.03	2024-04-23
665	665	7	north	7567.31	2023-12-27
666	666	15	south	4807.99	2023-08-31
667	667	8	north	3500.12	2024-04-26
668	668	14	south	8187.31	2024-02-07
669	669	9	north	6219.74	2023-10-28
670	670	9	north	486.67	2024-05-04
671	671	11	south	5935.48	2023-10-19
672	672	5	north	5725.15	2024-01-11
673	673	11	south	513.96	2023-09-04
674	674	11	south	2492.10	2024-04-22
675	675	18	south	3250.84	2023-08-03
676	676	6	north	4935.79	2024-05-14
677	677	14	south	8110.35	2024-04-07
678	678	2	north	2330.94	2024-06-11
679	679	5	north	8974.94	2024-06-06
680	680	13	south	447.58	2024-01-30
681	681	2	north	2793.42	2023-10-11
682	682	2	north	9879.45	2024-04-30
683	683	4	north	3250.45	2024-03-02
684	684	1	north	3285.90	2023-08-25
685	685	5	north	3625.34	2024-02-01
686	686	12	south	4893.65	2023-09-13
687	687	20	south	8690.13	2024-05-05
688	688	12	south	5462.41	2024-05-15
689	689	5	north	7197.91	2024-03-04
690	690	5	north	834.61	2023-12-20
691	691	13	south	7437.59	2024-02-11
692	692	10	north	6489.19	2023-10-19
693	693	8	north	4343.51	2024-02-20
694	694	6	north	2314.10	2023-08-07
695	695	14	south	5523.49	2024-02-23
696	696	20	south	795.61	2023-09-23
697	697	3	north	2965.99	2024-01-13
698	698	20	south	6479.46	2023-07-27
699	699	16	south	2638.28	2024-04-26
700	700	5	north	7892.27	2023-08-04
701	701	14	south	637.71	2024-07-24
702	702	1	north	6879.07	2023-11-19
703	703	9	north	3464.00	2023-09-05
704	704	14	south	3450.42	2024-06-16
705	705	2	north	4892.50	2024-07-22
706	706	17	south	3148.33	2024-03-21
707	707	20	south	3842.03	2024-04-27
708	708	15	south	929.48	2024-04-05
709	709	13	south	5409.26	2024-06-19
710	710	12	south	1039.45	2023-11-03
711	711	7	north	780.23	2024-01-20
712	712	10	north	4292.76	2023-10-09
713	713	17	south	5820.10	2023-12-19
714	714	11	south	7451.78	2024-07-25
715	715	3	north	3602.64	2023-09-22
716	716	9	north	3755.08	2024-04-29
717	717	6	north	9242.84	2024-06-08
718	718	3	north	4437.77	2024-04-16
719	719	13	south	197.24	2023-10-29
720	720	9	north	6489.00	2023-09-27
721	721	6	north	5696.14	2023-09-26
722	722	10	north	150.36	2024-04-23
723	723	11	south	5435.87	2023-10-07
724	724	19	south	6805.45	2024-02-06
725	725	13	south	4976.48	2024-01-18
726	726	10	north	8907.51	2024-01-04
727	727	9	north	855.68	2024-06-12
728	728	7	north	8447.82	2024-03-04
729	729	6	north	637.39	2024-02-14
730	730	12	south	6714.32	2023-12-08
731	731	5	north	4078.69	2024-02-15
732	732	6	north	484.66	2024-01-25
733	733	13	south	6968.65	2024-04-20
734	734	20	south	3548.60	2024-01-01
735	735	9	north	4632.15	2024-02-18
736	736	18	south	24.46	2023-12-03
737	737	4	north	619.23	2023-08-22
738	738	12	south	4335.14	2023-10-05
739	739	18	south	127.06	2023-10-14
740	740	9	north	9525.73	2024-01-03
741	741	3	north	4496.68	2024-02-07
742	742	8	north	4654.09	2024-02-10
743	743	14	south	2773.70	2024-05-18
744	744	4	north	8581.69	2024-05-04
745	745	17	south	3762.69	2023-11-12
746	746	15	south	339.37	2024-03-13
747	747	11	south	9262.25	2023-11-17
748	748	8	north	7891.29	2024-07-02
749	749	16	south	6800.62	2023-11-20
750	750	19	south	989.51	2023-09-11
751	751	11	south	546.16	2023-09-24
752	752	20	south	2517.43	2023-08-01
753	753	10	north	8368.55	2024-04-03
754	754	11	south	6543.49	2023-11-10
755	755	5	north	1373.15	2023-08-26
756	756	10	north	2641.18	2024-07-09
757	757	10	north	218.75	2023-09-03
758	758	7	north	253.75	2024-04-22
759	759	14	south	6439.06	2023-08-23
760	760	12	south	3683.56	2024-01-20
761	761	1	north	3601.97	2023-08-26
762	762	15	south	973.80	2024-04-13
763	763	19	south	5269.57	2023-08-09
764	764	19	south	1639.44	2024-03-06
765	765	17	south	4747.98	2023-08-31
766	766	8	north	429.99	2024-07-21
767	767	20	south	1831.65	2024-03-02
768	768	4	north	9470.57	2024-07-15
769	769	11	south	3502.04	2024-07-03
770	770	20	south	2922.33	2023-11-11
771	771	7	north	6705.36	2024-03-11
772	772	10	north	9020.82	2024-06-11
773	773	6	north	3568.64	2024-04-20
774	774	7	north	166.59	2024-05-25
775	775	19	south	9896.78	2024-07-01
776	776	12	south	4754.41	2024-06-27
777	777	20	south	6048.44	2024-02-23
778	778	16	south	7703.80	2024-07-04
779	779	2	north	7242.23	2024-04-01
780	780	12	south	503.55	2023-12-27
781	781	5	north	6054.93	2024-03-09
782	782	11	south	9292.74	2024-06-14
783	783	4	north	7369.13	2023-08-16
784	784	15	south	9463.93	2024-07-04
785	785	11	south	7942.84	2024-01-09
786	786	13	south	2100.08	2024-04-02
787	787	12	south	1215.79	2024-01-14
788	788	19	south	1227.19	2024-01-02
789	789	18	south	9925.23	2023-11-02
790	790	13	south	23.80	2024-05-02
791	791	6	north	1486.10	2024-05-28
792	792	8	north	4043.01	2023-11-03
793	793	15	south	2222.67	2023-10-06
794	794	4	north	9323.20	2023-12-26
795	795	13	south	7645.50	2023-10-04
796	796	8	north	3595.68	2024-04-13
797	797	6	north	2419.28	2024-04-08
798	798	16	south	8438.09	2023-10-25
799	799	19	south	645.26	2023-08-20
800	800	18	south	9887.33	2024-05-05
801	801	19	south	5332.26	2024-06-06
802	802	3	north	560.91	2023-12-22
803	803	6	north	501.87	2024-04-06
804	804	13	south	6377.76	2023-08-12
805	805	19	south	2069.97	2023-09-02
806	806	11	south	4696.75	2024-06-20
807	807	8	north	271.45	2024-01-17
808	808	10	north	9978.60	2023-08-01
809	809	6	north	4742.06	2024-01-02
810	810	2	north	6830.30	2023-08-13
811	811	17	south	6818.12	2024-05-29
812	812	13	south	3558.52	2023-08-06
813	813	6	north	1715.76	2024-05-08
814	814	12	south	5367.66	2023-08-11
815	815	13	south	3142.88	2024-02-05
816	816	9	north	3490.16	2024-03-09
817	817	10	north	2460.11	2024-01-04
818	818	14	south	7971.97	2023-12-20
819	819	7	north	9308.46	2023-12-09
820	820	9	north	470.54	2024-05-01
821	821	16	south	7639.14	2023-10-09
822	822	17	south	4519.73	2024-03-04
823	823	17	south	934.19	2024-01-26
824	824	16	south	4869.43	2023-10-19
825	825	9	north	6127.14	2023-09-10
826	826	12	south	5463.93	2023-08-21
827	827	15	south	3585.32	2024-06-11
828	828	2	north	6402.49	2023-11-18
829	829	8	north	7856.25	2023-08-09
830	830	11	south	2222.05	2024-05-20
831	831	11	south	8746.74	2024-02-19
832	832	11	south	4169.09	2024-02-13
833	833	12	south	2246.91	2024-02-26
834	834	13	south	1285.12	2024-04-17
835	835	17	south	1721.56	2024-05-07
836	836	19	south	7966.76	2024-02-11
837	837	9	north	7054.28	2024-01-25
838	838	3	north	7677.99	2023-12-18
839	839	17	south	1610.14	2024-05-13
840	840	16	south	1557.82	2024-06-27
841	841	10	north	3924.45	2024-04-09
842	842	18	south	1883.21	2023-12-12
843	843	4	north	1623.54	2024-02-25
844	844	6	north	1718.87	2023-09-03
845	845	15	south	9193.31	2024-07-16
846	846	18	south	3562.17	2024-06-21
847	847	3	north	8804.87	2023-09-26
848	848	14	south	2655.88	2023-10-31
849	849	3	north	2215.73	2024-02-25
850	850	8	north	1477.55	2023-07-27
851	851	9	north	4019.19	2024-06-01
852	852	8	north	2271.88	2023-12-02
853	853	18	south	7813.07	2023-10-02
854	854	8	north	6597.96	2023-08-18
855	855	2	north	1907.68	2024-02-21
856	856	6	north	6161.45	2024-03-16
857	857	9	north	8353.75	2023-12-24
858	858	5	north	5424.47	2024-06-04
859	859	7	north	7588.64	2023-09-28
860	860	3	north	9525.99	2024-06-11
861	861	4	north	1171.76	2024-01-02
862	862	15	south	6416.67	2024-01-29
863	863	20	south	627.35	2023-12-16
864	864	17	south	7371.35	2024-03-30
865	865	13	south	2359.76	2024-04-08
866	866	14	south	3518.54	2024-02-05
867	867	20	south	5610.50	2024-07-08
868	868	20	south	675.10	2024-06-12
869	869	14	south	3041.57	2023-10-10
870	870	3	north	8225.44	2023-08-23
871	871	2	north	5371.38	2024-04-23
872	872	8	north	1770.20	2023-12-30
873	873	14	south	774.13	2024-03-19
874	874	20	south	9565.56	2024-03-09
875	875	6	north	4944.99	2023-10-09
876	876	14	south	9282.78	2023-10-31
877	877	9	north	8749.17	2023-08-25
878	878	12	south	1907.86	2023-09-16
879	879	20	south	3589.51	2023-12-06
880	880	10	north	111.48	2024-03-14
881	881	15	south	8770.73	2024-04-21
882	882	8	north	2141.06	2023-11-02
883	883	9	north	8969.39	2023-10-25
884	884	19	south	5640.23	2024-04-17
885	885	11	south	3683.68	2024-04-11
886	886	9	north	9577.80	2024-01-15
887	887	8	north	6747.70	2023-10-24
888	888	14	south	5875.67	2024-01-21
889	889	1	north	7144.32	2024-07-20
890	890	6	north	4058.35	2023-12-29
891	891	8	north	1260.62	2024-03-11
892	892	10	north	3329.44	2024-01-13
893	893	3	north	6331.74	2024-06-08
894	894	19	south	5796.52	2023-09-06
895	895	16	south	5507.85	2024-05-12
896	896	6	north	2117.12	2024-05-27
897	897	2	north	8884.00	2024-03-11
898	898	16	south	1451.68	2023-08-13
899	899	7	north	8963.40	2023-08-18
900	900	3	north	6740.86	2024-01-29
901	901	6	north	1379.84	2023-11-25
902	902	20	south	832.32	2023-12-08
903	903	2	north	8217.29	2023-09-10
904	904	9	north	9393.82	2024-06-24
905	905	20	south	5708.55	2024-02-20
906	906	3	north	8720.63	2023-11-15
907	907	20	south	9537.06	2024-01-07
908	908	2	north	7513.16	2024-05-14
909	909	19	south	7902.76	2024-03-27
910	910	4	north	4671.23	2023-09-27
911	911	8	north	3095.90	2024-06-20
912	912	2	north	5853.22	2024-04-28
913	913	3	north	372.93	2023-10-16
914	914	13	south	916.41	2024-01-14
915	915	9	north	6955.16	2023-12-28
916	916	5	north	989.16	2024-04-27
917	917	6	north	3236.00	2023-11-18
918	918	4	north	2214.86	2024-03-25
919	919	13	south	6467.01	2023-08-18
920	920	7	north	1563.50	2024-01-31
921	921	2	north	8427.18	2024-03-14
922	922	18	south	9061.94	2023-11-14
923	923	6	north	2268.83	2023-11-23
924	924	4	north	3042.10	2023-09-15
925	925	16	south	8840.90	2024-03-17
926	926	8	north	8837.01	2024-02-06
927	927	9	north	5349.40	2024-01-25
928	928	17	south	4.89	2024-03-15
929	929	5	north	6146.08	2023-08-04
930	930	12	south	9534.53	2023-12-07
931	931	5	north	2849.09	2024-01-12
932	932	3	north	2955.32	2023-09-09
933	933	19	south	4618.95	2023-08-21
934	934	5	north	5753.25	2023-11-13
935	935	9	north	8810.10	2023-08-27
936	936	9	north	4309.09	2024-07-12
937	937	18	south	585.74	2023-09-20
938	938	4	north	3816.16	2024-05-18
939	939	13	south	3423.24	2024-06-21
940	940	13	south	1027.78	2024-03-29
941	941	13	south	5390.56	2024-07-22
942	942	4	north	8147.37	2023-08-31
943	943	10	north	5482.24	2024-07-18
944	944	16	south	8614.43	2023-08-04
945	945	7	north	2707.44	2024-04-04
946	946	11	south	3512.20	2023-11-15
947	947	10	north	7781.40	2023-08-28
948	948	11	south	6427.43	2024-01-25
949	949	9	north	2544.67	2024-02-11
950	950	10	north	5654.64	2024-05-16
951	951	17	south	6040.55	2024-02-23
952	952	18	south	2566.00	2023-08-27
953	953	20	south	54.55	2023-09-09
954	954	16	south	2711.15	2023-08-23
955	955	11	south	1298.40	2023-12-21
956	956	19	south	9901.19	2024-04-07
957	957	9	north	5818.24	2024-07-06
958	958	6	north	9419.11	2023-11-09
959	959	14	south	8407.23	2024-04-22
960	960	8	north	3831.97	2024-05-11
961	961	7	north	4362.68	2023-12-22
962	962	12	south	8147.58	2023-09-25
963	963	14	south	9036.28	2023-11-22
964	964	8	north	4839.11	2023-08-09
965	965	15	south	4087.36	2024-06-07
966	966	18	south	3227.83	2024-05-21
967	967	5	north	9846.31	2023-07-30
968	968	13	south	4339.08	2023-07-31
969	969	17	south	4123.11	2024-03-18
970	970	1	north	8304.51	2024-03-12
971	971	20	south	7479.49	2023-10-07
972	972	19	south	3277.88	2023-12-14
973	973	10	north	6860.87	2024-03-22
974	974	1	north	5195.68	2023-11-03
975	975	5	north	3172.99	2023-09-15
976	976	2	north	8237.05	2024-02-19
977	977	14	south	947.75	2024-06-29
978	978	2	north	363.03	2024-06-18
979	979	20	south	9837.90	2024-04-03
980	980	20	south	7534.47	2023-10-31
981	981	8	north	3043.66	2024-05-01
982	982	10	north	185.38	2023-10-04
983	983	18	south	4436.46	2024-04-08
984	984	19	south	2763.32	2023-11-16
985	985	1	north	8622.93	2023-11-16
986	986	9	north	4618.71	2023-12-06
987	987	15	south	7818.12	2024-02-21
988	988	7	north	6236.92	2023-08-18
989	989	20	south	6006.43	2023-09-09
990	990	20	south	3306.64	2024-05-19
991	991	11	south	7620.05	2023-09-18
992	992	10	north	7171.35	2023-09-30
993	993	15	south	2178.22	2024-06-11
994	994	5	north	1889.15	2023-12-31
995	995	2	north	8755.68	2023-09-15
996	996	3	north	9310.35	2024-04-09
997	997	2	north	6727.16	2024-02-16
998	998	14	south	267.57	2023-09-17
999	999	8	north	4947.87	2023-12-23
1000	1000	2	north	1252.31	2024-04-19
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
1	north	North Branch 1	100	2333631.43
2	north	North Branch 2	100	7704409.49
3	north	North Branch 3	100	2086097.60
4	north	North Branch 4	100	3431281.19
5	north	North Branch 5	100	4958553.99
6	north	North Branch 6	100	9783712.52
7	north	North Branch 7	100	2545001.08
8	north	North Branch 8	100	2344570.75
9	north	North Branch 9	100	536045.84
10	north	North Branch 10	100	8712292.22
\.


--
-- Data for Name: bankbranches_south; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.bankbranches_south (bank_id, bank_region, bank_name, account_num, total_funds) FROM stdin;
11	south	South Branch 1	100	8287984.87
12	south	South Branch 2	100	4621821.30
13	south	South Branch 3	100	2241501.74
14	south	South Branch 4	100	767573.39
15	south	South Branch 5	100	9356338.98
16	south	South Branch 6	100	9257619.58
17	south	South Branch 7	100	29251.13
18	south	South Branch 8	100	3751233.65
19	south	South Branch 9	100	8113082.52
20	south	South Branch 10	100	3363647.38
\.


--
-- Data for Name: marketsurvey; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.marketsurvey (survey_id, survey_title, survey_des, survey_response) FROM stdin;
1	Survey 1	Description 1	{"response": "response1"}
2	Survey 2	Description 2	{"response": "response2"}
3	Survey 3	Description 3	{"response": "response3"}
4	Survey 4	Description 4	{"response": "response4"}
5	Survey 5	Description 5	{"response": "response5"}
6	Survey 6	Description 6	{"response": "response6"}
7	Survey 7	Description 7	{"response": "response7"}
8	Survey 8	Description 8	{"response": "response8"}
9	Survey 9	Description 9	{"response": "response9"}
10	Survey 10	Description 10	{"response": "response10"}
\.


--
-- Data for Name: transaction_history; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.transaction_history (trans_id, trans_time, trans_sourceid, trans_amount, trans_targetid, trans_reason, trans_method) FROM stdin;
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
-- Name: account_info_his_his_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.account_info_his_his_id_seq', 1, false);


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

SELECT pg_catalog.setval('public.marketsurvey_survey_id_seq', 10, true);


--
-- Name: transaction_history_trans_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.transaction_history_trans_id_seq', 1, false);


--
-- Name: user_information_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_information_user_id_seq', 1000, true);


--
-- Name: account_info_his account_info_his_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_info_his
    ADD CONSTRAINT account_info_his_pkey PRIMARY KEY (his_id);


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
-- Name: transaction_history transaction_history_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transaction_history
    ADD CONSTRAINT transaction_history_pkey PRIMARY KEY (trans_id);


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
-- Name: transaction_history transaction_history_trans_sourceid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transaction_history
    ADD CONSTRAINT transaction_history_trans_sourceid_fkey FOREIGN KEY (trans_sourceid) REFERENCES public.account_information(account_id);


--
-- Name: transaction_history transaction_history_trans_targetid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transaction_history
    ADD CONSTRAINT transaction_history_trans_targetid_fkey FOREIGN KEY (trans_targetid) REFERENCES public.account_information(account_id);


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


--
-- Name: TABLE account_credentials; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.account_credentials TO chung;


--
-- Name: TABLE account_info_his; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.account_info_his TO chung;


--
-- Name: SEQUENCE account_info_his_his_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.account_info_his_his_id_seq TO chung;


--
-- Name: TABLE account_information; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.account_information TO chung;


--
-- Name: SEQUENCE account_information_account_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.account_information_account_id_seq TO chung;


--
-- Name: TABLE bankbranches; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.bankbranches TO chung;


--
-- Name: TABLE user_information; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.user_information TO chung;


--
-- Name: TABLE account_view; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.account_view TO chung;


--
-- Name: SEQUENCE bankbranches_bank_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.bankbranches_bank_id_seq TO chung;


--
-- Name: TABLE bankbranches_default; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.bankbranches_default TO chung;


--
-- Name: TABLE bankbranches_north; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.bankbranches_north TO chung;


--
-- Name: TABLE bankbranches_south; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.bankbranches_south TO chung;


--
-- Name: TABLE marketsurvey; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.marketsurvey TO chung;


--
-- Name: SEQUENCE marketsurvey_survey_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.marketsurvey_survey_id_seq TO chung;


--
-- Name: TABLE transaction_history; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.transaction_history TO chung;


--
-- Name: SEQUENCE transaction_history_trans_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.transaction_history_trans_id_seq TO chung;


--
-- Name: SEQUENCE user_information_user_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.user_information_user_id_seq TO chung;


--
-- PostgreSQL database dump complete
--

--
-- PostgreSQL database cluster dump complete
--

