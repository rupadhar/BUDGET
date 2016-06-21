create or replace PACKAGE                                                                                                                                                                                                                                                                                                                                                                                                                         "BUDGET"
IS
    g_managecontrolnumbers   VARCHAR2 (30) := 'MANAGECONTROLNUMBERS';
    g_insufficientrights     VARCHAR2 (44)
        := 'Insufficient Rights To Perform Budget Action';

    TYPE t_dept_rec IS RECORD
    (
        key_global_dept     hsc.hart_global_depts_mv.key_global_dept%TYPE,
        global_dept_name    hsc.hart_global_depts_mv.global_dept_name%TYPE,
        total               funds.amount%TYPE,
        nonsalary_total     funds.nonsalary_amount%TYPE,
        fundlastupdate      funds.lastupdated%TYPE,
        productlastupdate   funds.lastupdated%TYPE,
        college_code        hsc.hart_global_depts_mv.college_code%TYPE
    );
    

    FUNCTION can_manage_new_fund_requests (
        p_personid        IN person_userroles_active.person_id%TYPE,
        p_keyglobaldept   IN person_userroles_active.key_global_dept%TYPE,
        p_writeaccess     IN userroles.writeaccess%TYPE DEFAULT 'Y') RETURN NUMBER;


    FUNCTION get_fy_start (p_fy IN NUMBER)
        RETURN DATE;

    FUNCTION get_fy_end (p_fy IN NUMBER)
        RETURN DATE;

    FUNCTION can_manage_dept_personnels (
        p_personid        IN person_userroles_active.person_id%TYPE,
        p_keyglobaldept   IN person_userroles_active.key_global_dept%TYPE,
        p_writeaccess     IN userroles.writeaccess%TYPE DEFAULT 'Y')
        RETURN NUMBER;

    PROCEDURE ins_db_audit_log(
        p_procName IN db_call_audit_log.proc_name%type,
        p_user  IN db_call_audit_log.hscnet_id%type,
        p_file IN db_call_audit_log.file_called_from%type,
        p_query IN db_call_audit_log.query_string%type,
        p_deptid IN DB_CALL_AUDIT_LOG.KEY_GLOBAL_DEPT%TYPE,
        p_rem_ip IN db_call_audit_log.remote_ip%type);

    PROCEDURE get_current_user_information (
        p_personid    IN     hsc.sd_hsc_directory.person_id%TYPE,
        p_firstname      OUT hsc.sd_hsc_directory.first_name%TYPE,
        p_lastname       OUT hsc.sd_hsc_directory.last_name%TYPE,
        p_email          OUT hsc.sd_hsc_directory.email_id%TYPE,
        curr_roles       OUT SYS_REFCURSOR);

    PROCEDURE get_system_roles (curr_roles IN OUT SYS_REFCURSOR);

    PROCEDURE get_users_roles (
        p_personid   IN     person_userroles_active.person_id%TYPE,
        curr_roles   IN OUT SYS_REFCURSOR);

    PROCEDURE search_user (p_search       IN     VARCHAR2,
                           curr_results   IN OUT SYS_REFCURSOR);

    FUNCTION has_access_change_role (
        p_adminpersonid   IN person_userroles_active.person_id%TYPE,
        p_userroleid      IN userroles.userroleid%TYPE)
        RETURN BOOLEAN;

    PROCEDURE ins_user_role (
        p_adminpersonid   IN     person_userroles_active.person_id%TYPE,
        p_personid        IN     person_userroles_active.person_id%TYPE,
        p_userroleid      IN     userroles.userroleid%TYPE,
        p_effectivedate   IN     person_userroles_active.effectivedate%TYPE,
        p_keyglobaldept   IN     person_userroles_active.key_global_dept%TYPE,
        p_collegecode     IN     person_userroles_active.college_code%TYPE,
        p_firstname          OUT hsc.sd_hsc_directory.first_name%TYPE,
        p_lastname           OUT hsc.sd_hsc_directory.last_name%TYPE);

     PROCEDURE get_user_roles_for_admin (
        p_adminpersonid   IN     person_userroles_active.person_id%TYPE,
        p_personid        IN     person_userroles_active.person_id%TYPE,
        p_status          IN     VARCHAR2,
        curr_roles           OUT SYS_REFCURSOR);

    PROCEDURE get_user_data_for_admin (
        p_adminpersonid   IN     person_userroles_active.person_id%TYPE,
        p_personid        IN     person_userroles_active.person_id%TYPE,
        p_status          IN     VARCHAR2,
        p_hscid              OUT hsc.sd_hsc_directory.hscid%TYPE,
        p_firstname          OUT hsc.sd_hsc_directory.first_name%TYPE,
        p_lastname           OUT hsc.sd_hsc_directory.last_name%TYPE,
        curr_roles           OUT SYS_REFCURSOR,
        curr_colleges        OUT SYS_REFCURSOR);

    PROCEDURE upd_disable_user_role_date (
        p_adminpersonid   IN person_userroles_active.person_id%TYPE,
        p_personid        IN person_userroles_active.person_id%TYPE,
        p_userroleid      IN person_userroles_active.userroleid%TYPE,
        p_effectivedate   IN person_userroles_active.effectivedate%TYPE,
        p_keyglobaldept   IN person_userroles_active.key_global_dept%TYPE,
        p_collegecode     IN person_userroles_active.college_code%TYPE,
        p_disabledate     IN person_userroles_active.disableddate%TYPE);

    PROCEDURE get_directory_name (
        p_personid    IN     hsc.sd_hsc_directory.person_id%TYPE,
        p_firstname      OUT hsc.sd_hsc_directory.first_name%TYPE,
        p_lastname       OUT hsc.sd_hsc_directory.last_name%TYPE);

    PROCEDURE log_admin_action (
        p_adminpersonid   IN person_userroles_log.adminperson_id%TYPE,
        p_personid        IN person_userroles_log.person_id%TYPE,
        p_userroleid      IN person_userroles_log.userroleid%TYPE,
        p_keyglobaldept   IN person_userroles_log.key_global_dept%TYPE,
        p_collegecode     IN person_userroles_log.college_code%TYPE,
        p_description     IN person_userroles_log.description%TYPE);

    PROCEDURE get_global_departments (curr_departments OUT SYS_REFCURSOR);

    PROCEDURE get_depts_control_data (
        p_personid     IN     person_userroles_active.person_id%TYPE,
        p_fiscalyear   IN     funds.budget_fy%TYPE,
        curr_depts        OUT SYS_REFCURSOR);

    PROCEDURE get_dept_control_totals (
        p_personid         IN     person_userroles_active.person_id%TYPE,
        p_keydeptprofile   IN     funds.key_dept_profile%TYPE,
        p_fiscalyear       IN     funds.budget_fy%TYPE,
        curr_depts            OUT SYS_REFCURSOR);

    PROCEDURE get_global_dept_control_total (
        p_personid        IN     person_userroles_active.person_id%TYPE,
        p_keyglobaldept   IN     person_userroles_active.key_global_dept%TYPE,
        p_fiscalyear      IN     funds.budget_fy%TYPE,
        r_total              OUT funds.amount%TYPE);

    PROCEDURE get_dept_control_total (
        p_personid         IN     person_userroles_active.person_id%TYPE,
        p_keydeptprofile   IN     funds.key_dept_profile%TYPE,
        p_fiscalyear       IN     funds.budget_fy%TYPE,
        r_total               OUT funds.amount%TYPE,
        r_nonsalarytotal      OUT funds.nonsalary_amount%TYPE);

    PROCEDURE get_global_dept_control_totals (
        p_personid        IN     person_userroles_active.person_id%TYPE,
        p_keyglobaldept   IN     person_userroles_active.key_global_dept%TYPE,
        p_fiscalyear      IN     funds.budget_fy%TYPE,
        curr_depts           OUT SYS_REFCURSOR);

    PROCEDURE get_salary_rate_details (
        p_personid         IN     person_userroles_active.person_id%TYPE,
        p_keydeptprofile   IN     salary_rate_details.key_dept_profile%TYPE,
        p_fiscalyear       IN     funds.budget_fy%TYPE,
        curr_details          OUT SYS_REFCURSOR);

    PROCEDURE get_dept_funds (
        p_personid                IN     person_userroles_active.person_id%TYPE,
        p_keydeptprofile          IN     funds.key_dept_profile%TYPE,
        p_fiscalyear              IN     funds.budget_fy%TYPE,
        p_hasaccess                  OUT NUMBER,
        curr_funds_control_nums      OUT SYS_REFCURSOR,
        curr_details                 OUT SYS_REFCURSOR);

    PROCEDURE ins_fund (
        p_personid             IN     person_userroles_active.person_id%TYPE,
        p_keydeptprofile       IN     funds.key_dept_profile%TYPE,
        p_name                 IN     funds.name%TYPE,
        p_chartfield           IN     funds.chartfield%TYPE,
        p_facultyamount        IN     funds.faculty_amount%TYPE,
        p_staffamount          IN     funds.staff_amount%TYPE,
        p_nonsalaryamount      IN     funds.nonsalary_amount%TYPE,
        p_effectivedate        IN     funds.effective_date%TYPE,
        p_fiscalyear           IN     funds.budget_fy%TYPE,
        r_newdepttotal            OUT funds.amount%TYPE,
        r_newnonsalarytotal       OUT funds.nonsalary_amount%TYPE,
        curr_refreshed_funds      OUT SYS_REFCURSOR);

    PROCEDURE upd_fund (
        p_personid            IN     person_userroles_active.person_id%TYPE,
        p_fundid              IN     funds.fundid%TYPE,
        p_name                IN     funds.name%TYPE,
        p_chartfield          IN     funds.chartfield%TYPE,
        p_facultyamount       IN     funds.faculty_amount%TYPE,
        p_staffamount         IN     funds.staff_amount%TYPE,
        p_nonsalaryamount     IN     funds.nonsalary_amount%TYPE,
        p_effectivedate       IN     funds.effective_date%TYPE,
        curr_funds               OUT SYS_REFCURSOR,
        r_newtotal               OUT funds.amount%TYPE,
        r_newnonsalarytotal      OUT funds.nonsalary_amount%TYPE);

    PROCEDURE ins_fund_product (
        p_personid                IN     person_userroles_active.person_id%TYPE,
        p_fundid                  IN     fund_products.fundid%TYPE,
        p_name                    IN     fund_products.name%TYPE,
        p_chartfield              IN     fund_products.chartfield%TYPE,
        p_facultyamount           IN     fund_products.faculty_amount%TYPE,
        p_staffamount             IN     fund_products.staff_amount%TYPE,
        p_nonsalaryamount         IN     fund_products.nonsalary_amount%TYPE,
        p_effectivedate           IN     fund_products.effective_date%TYPE,
        p_adjustfund              IN     NUMBER DEFAULT 0,
        r_newfundtotal               OUT funds.amount%TYPE,
        r_newnonsalarytotal          OUT funds.nonsalary_amount%TYPE,
        r_keydeptprofile             OUT funds.key_dept_profile%TYPE,
        curr_refreshed_products      OUT SYS_REFCURSOR);

    PROCEDURE get_funds_control_nums (
        p_keydeptprofile          IN     funds.key_dept_profile%TYPE,
        p_hasaccess               IN     NUMBER,
        p_fiscalyear              IN     funds.budget_fy%TYPE,
        curr_funds_control_nums      OUT SYS_REFCURSOR);

    PROCEDURE get_fund_products (
        p_personid           IN     person_userroles_active.person_id%TYPE,
        p_fundid             IN     funds.fundid%TYPE,
        r_hasaccess             OUT NUMBER,
        curr_fund_products      OUT SYS_REFCURSOR);

    PROCEDURE del_fund (
        p_personid             IN     person_userroles_active.person_id%TYPE,
        p_keydeptprofile       IN     funds.key_dept_profile%TYPE,
        p_fundid               IN     funds.fundid%TYPE,
        r_newdepttotal            OUT funds.amount%TYPE,
        r_newnonsalarytotal       OUT funds.nonsalary_amount%TYPE,
        curr_refreshed_funds      OUT SYS_REFCURSOR);

    PROCEDURE del_fund_product (
        p_personid                IN     person_userroles_active.person_id%TYPE,
        p_fundid                  IN     fund_products.fundid%TYPE,
        p_fundproductid           IN     fund_products.fundproductid%TYPE,
        r_newfundtotal               OUT funds.amount%TYPE,
        r_newnonsalarytotal          OUT funds.nonsalary_amount%TYPE,
        r_keydeptprofile             OUT funds.key_dept_profile%TYPE,
        curr_refreshed_products      OUT SYS_REFCURSOR);

    PROCEDURE upd_fund_product (
        p_personid            IN     person_userroles_active.person_id%TYPE,
        p_fundproductid       IN     fund_products.fundproductid%TYPE,
        p_name                IN     fund_products.name%TYPE,
        p_chartfield          IN     fund_products.chartfield%TYPE,
        p_facultyamount       IN     fund_products.faculty_amount%TYPE,
        p_staffamount         IN     fund_products.staff_amount%TYPE,
        p_nonsalaryamount     IN     fund_products.nonsalary_amount%TYPE,
        p_effective_date      IN     fund_products.effective_date%TYPE,
        p_adjustfund          IN     NUMBER,
        r_confirmadjustment      OUT VARCHAR2,
        r_newfundtotal           OUT funds.amount%TYPE,
        r_newnonsalarytotal      OUT funds.amount%TYPE,
        r_keydeptprofile         OUT funds.key_dept_profile%TYPE,
        curr_fund_products       OUT SYS_REFCURSOR);

    PROCEDURE get_updated_fund_product_data (
        p_personid            IN     person_userroles_active.person_id%TYPE,
        p_fundid              IN     funds.fundid%TYPE,
        r_keydeptprofile         OUT funds.key_dept_profile%TYPE,
        r_newfundtotal           OUT funds.amount%TYPE,
        r_newnonsalarytotal      OUT funds.nonsalary_amount%TYPE,
        curr_fund_products       OUT SYS_REFCURSOR);

    PROCEDURE ins_salary_rate_detail (
        p_personid               IN     person_userroles_active.person_id%TYPE,
        p_keydeptprofile         IN     salary_rate_details.key_dept_profile%TYPE,
        p_description            IN     salary_rate_details.description%TYPE,
        p_facultyamount          IN     salary_rate_details.faculty_amount%TYPE,
        p_staffamount            IN     salary_rate_details.staff_amount%TYPE,
        p_totalamount            IN     salary_rate_details.total_amount%TYPE,
        p_effectivedate          IN     salary_rate_details.effective_date%TYPE,
        p_fiscalyear             IN     salary_rate_details.budget_fy%TYPE,
        curr_refreshed_details      OUT SYS_REFCURSOR);

    PROCEDURE del_salary_rate_detail (
        p_personid               IN     person_userroles_active.person_id%TYPE,
        p_keydeptprofile         IN     salary_rate_details.key_dept_profile%TYPE,
        p_salaryratedetailid     IN     salary_rate_details.salaryratedetailid%TYPE,
        curr_refreshed_details      OUT SYS_REFCURSOR);

    PROCEDURE upd_salary_rate_detail (
        p_personid             IN     person_userroles_active.person_id%TYPE,
        p_keydeptprofile       IN     salary_rate_details.key_dept_profile%TYPE,
        p_salaryratedetailid   IN     salary_rate_details.salaryratedetailid%TYPE,
        p_description          IN     salary_rate_details.description%TYPE,
        p_facultyamount        IN     salary_rate_details.faculty_amount%TYPE,
        p_staffamount          IN     salary_rate_details.staff_amount%TYPE,
        p_totalamount          IN     salary_rate_details.total_amount%TYPE,
        p_effectivedate        IN     salary_rate_details.effective_date%TYPE,
        curr_details              OUT SYS_REFCURSOR);

    PROCEDURE chartfield_suggest_search (
        p_personid         IN     person_userroles_active.person_id%TYPE,
        p_keydeptprofile   IN     hsc.usf_dept_profile_mv.key_dept_profile%TYPE,
        p_searchterm       IN     hsc.usf_dept_profile_mv.usf_dept_code%TYPE,
        p_context          IN     VARCHAR2,
        curr_results          OUT SYS_REFCURSOR);

    PROCEDURE get_state_funds_classes (curr_classes OUT SYS_REFCURSOR);

    PROCEDURE get_state_fund_request_deps (
        curr_classes              OUT SYS_REFCURSOR,
        curr_request_types        OUT SYS_REFCURSOR,
        curr_ous                  OUT SYS_REFCURSOR,
        curr_distribution_types   OUT SYS_REFCURSOR);

    PROCEDURE sel_state_fund_requests (
        p_keyglobaldept         IN     state_funds_requests.key_global_dept%TYPE,
        p_statefundsrequestid   IN     state_funds_requests.statefundsrequestid%TYPE,
        p_fiscalyear            IN     state_funds_requests.budget_fy%TYPE,
        p_csvtype               IN     VARCHAR2,
        curr_fund_requests         OUT SYS_REFCURSOR);

    PROCEDURE get_state_fund_requests (
        p_personid           IN     person_userroles_active.person_id%TYPE,
        p_keyglobaldept      IN     state_funds_requests.key_global_dept%TYPE,
        p_fiscalyear         IN     state_funds_requests.budget_fy%TYPE,
        curr_fund_requests      OUT SYS_REFCURSOR);

    FUNCTION compute_prorated_funds (
        p_newannualrate    state_funds_requests.new_annual_rate%TYPE,
        p_hiremonth        state_funds_requests.hire_month%TYPE)
        RETURN NUMBER;

    PROCEDURE del_state_funds_requests (
        p_personid                   IN person_userroles_active.person_id%TYPE,
        p_keyglobaldept              IN state_funds_requests.key_global_dept%TYPE,
        p_csvstatefundsrequestsids   IN VARCHAR2);

    FUNCTION get_global_dept (
        p_keydeptprofile IN hsc.usf_dept_profile_mv.key_dept_profile%TYPE)
        RETURN hsc.usf_dept_profile_mv.key_global_dept%TYPE;

    PROCEDURE get_departments_for_global (
        p_personid        IN     person_userroles_active.person_id%TYPE,
        p_keyglobaldept   IN     hsc.usf_dept_profile_mv.key_global_dept%TYPE,
        p_fiscalyear      IN     funds.budget_fy%TYPE,
        curr_depts           OUT SYS_REFCURSOR);

    PROCEDURE search_user_full (
        p_personid        IN     person_userroles_active.person_id%TYPE,
        p_hscid           IN     VARCHAR2,
        p_keyglobaldept   IN     person_userroles_active.key_global_dept%TYPE,
        p_userroleid      IN     userroles.userroleid%TYPE,
        p_status          IN     VARCHAR2,
        curr_results         OUT SYS_REFCURSOR);

    PROCEDURE ins_state_funds_request (
        p_personid                  IN     person_userroles_active.person_id%TYPE,
        p_keyglobaldept             IN     state_funds_requests.key_global_dept%TYPE,
        p_lastname                  IN     state_funds_requests.last_name%TYPE,
        p_firstname                 IN     state_funds_requests.first_name%TYPE,
        p_statefundsclassid         IN     state_funds_requests.statefundsclassid%TYPE,
        p_positionnbr               IN     state_funds_requests.position_nbr%TYPE,
        p_jobtitle                  IN     state_funds_requests.job_title%TYPE,
        p_gemsid                    IN     state_funds_requests.gemsid%TYPE,
        p_currentannualrate         IN     state_funds_requests.current_annual_rate%TYPE,
        p_fundsrequestannual        IN     state_funds_requests.funds_request_annual%TYPE,
        p_newannualrate             IN     state_funds_requests.new_annual_rate%TYPE,
        p_hiremonth                 IN     state_funds_requests.hire_month%TYPE,
        p_statefundsrequesttypeid   IN     state_funds_requests.statefundsrequesttypeid%TYPE,
        p_justificationcomments     IN     state_funds_requests.justification_comments%TYPE,
        p_fiscalyear                IN     state_funds_requests.budget_fy%TYPE,
        r_statefundsrequestid          OUT state_funds_requests.statefundsrequestid%TYPE);

    PROCEDURE upd_state_funds_request (
        p_personid                  IN person_userroles_active.person_id%TYPE,
        p_statefundsrequestid       IN state_funds_requests.statefundsrequestid%TYPE,
        p_lastname                  IN state_funds_requests.last_name%TYPE,
        p_firstname                 IN state_funds_requests.first_name%TYPE,
        p_statefundsclassid         IN state_funds_requests.statefundsclassid%TYPE,
        p_positionnbr               IN state_funds_requests.position_nbr%TYPE,
        p_jobtitle                  IN state_funds_requests.job_title%TYPE,
        p_gemsid                    IN state_funds_requests.gemsid%TYPE,
        p_currentannualrate         IN state_funds_requests.current_annual_rate%TYPE,
        p_fundsrequestannual        IN state_funds_requests.funds_request_annual%TYPE,
        p_newannualrate             IN state_funds_requests.new_annual_rate%TYPE,
        p_hiremonth                 IN state_funds_requests.hire_month%TYPE,
        p_statefundsrequesttypeid   IN state_funds_requests.statefundsrequesttypeid%TYPE,
        p_justificationcomments     IN state_funds_requests.justification_comments%TYPE);

    PROCEDURE get_state_request_fringe (
        p_class                  IN     state_funds_classes.statefundsclassid%TYPE,
        r_stipendfringepercent      OUT misc_settings.stipend_fringe_percent%TYPE);

    PROCEDURE get_state_request_components (
        p_personid               IN     person_userroles_active.person_id%TYPE,
        p_statefundsrequestid    IN     state_reqst_pay_distributions.statefundsrequestid%TYPE,
        r_stipendfringepercent      OUT misc_settings.stipend_fringe_percent%TYPE,
        r_totalamount               OUT state_funds_requests.new_annual_rate%TYPE,
        r_fundrequeststatusid       OUT state_funds_requests.fundrequeststatusid%TYPE,
        curr_components             OUT SYS_REFCURSOR,
        curr_asf_components         OUT SYS_REFCURSOR);

    PROCEDURE get_state_fund_request_status (
        p_statefundsrequestid   IN     state_funds_requests.statefundsrequestid%TYPE,
        r_fundrequeststatusid      OUT state_funds_requests.fundrequeststatusid%TYPE);

    PROCEDURE compute_usfpg_tax_retirement (
        p_amount       IN     NUMBER,
        p_entity       IN     VARCHAR2,
        p_hiredate     IN     DATE,
        p_employeeid   IN     VARCHAR2,
        p_fy           IN     usfpg_fringe_values.fy%TYPE,
        r_retirement      OUT NUMBER,
        r_tax             OUT NUMBER);

    FUNCTION compute_usfpg_tax (
        p_annualrate   IN NUMBER,
        p_fy           IN usfpg_fringe_values.fy%TYPE)
        RETURN NUMBER;

       FUNCTION compute_usfpg_tbr_tax (
         p_annualrate   IN NUMBER,
        p_fy                       IN usfpg_fringe_values.fy%TYPE,
        p_total_annual_rate        IN cyborg_payroll_data.annualsalary%TYPE)
        RETURN NUMBER;

    FUNCTION compute_usfpg_retirement (
        p_companycode    IN NUMBER,
        p_hiredate       IN DATE,
        p_annualsalary   IN NUMBER,
        p_fy             IN usfpg_fringe_values.fy%TYPE)
        RETURN NUMBER;


 FUNCTION compute_usfpg_tbr_retirement (
        p_companycode         IN NUMBER,
        p_hiredate            IN DATE,
        p_annualsalary        IN NUMBER,
        p_fy                  IN usfpg_fringe_values.fy%TYPE,
        p_total_annual_rate   IN cyborg_payroll_data.annualsalary%TYPE)
        RETURN NUMBER;

/*
  PROCEDURE sel_pg_personnel_schd_export3 (
        p_keyglobaldept    IN     person_userroles_active.key_global_dept%TYPE,
        p_context          IN     VARCHAR2,
        p_emplid           IN     cyborg_payroll_data.employeenumber%TYPE,
        p_nextfiscalyear   IN     pg_pay_distribution_dates.fy%TYPE,
        curr_personnel        OUT SYS_REFCURSOR); */

    PROCEDURE sel_pg_personnel_schd_dist (
        p_emplid            IN     cyborg_payroll_hed_data.empl_id%TYPE,
        p_nextfiscalyear    IN     pg_pay_distribution_dates.fy%TYPE,
        curr_distribution      OUT SYS_REFCURSOR);

   PROCEDURE del_state_reqst_dists (
        p_personid                       IN person_userroles_active.person_id%TYPE,
        p_statefundsrequestid            IN state_reqst_pay_distributions.statefundsrequestid%TYPE,
        p_csvdeletedpaydistributionids   IN VARCHAR2);

    PROCEDURE upd_state_reqst_dist (
        p_personid                IN person_userroles_active.person_id%TYPE,
        p_statefundsrequestid     IN state_reqst_pay_distributions.statefundsrequestid%TYPE,
        p_paydistributionid       IN state_reqst_pay_distributions.paydistributionid%TYPE,
        p_ouid                    IN state_reqst_pay_distributions.ouid%TYPE,
        p_deptcode                IN state_reqst_pay_distributions.dept_code%TYPE,
        p_fundcode                IN state_reqst_pay_distributions.fund_code%TYPE,
        p_accountcode             IN state_reqst_pay_distributions.account_code%TYPE,
        p_productcode             IN state_reqst_pay_distributions.product_code%TYPE,
        p_initiative              IN state_reqst_pay_distributions.initiative%TYPE,
        p_projectcode             IN state_reqst_pay_distributions.project_code%TYPE,
        p_ucsamount               IN state_reqst_pay_distributions.ucs_dollars%TYPE,
        p_ucspercent              IN state_reqst_pay_distributions.ucs_percent%TYPE,
        p_paydistributiontypeid   IN state_reqst_pay_distributions.paydistributiontypeid%TYPE);

    PROCEDURE ins_state_reqst_dist (
        p_personid                IN person_userroles_active.person_id%TYPE,
        p_statefundsrequestid     IN state_reqst_pay_distributions.statefundsrequestid%TYPE,
        p_ouid                    IN state_reqst_pay_distributions.ouid%TYPE,
        p_deptcode                IN state_reqst_pay_distributions.dept_code%TYPE,
        p_fundcode                IN state_reqst_pay_distributions.fund_code%TYPE,
        p_accountcode             IN state_reqst_pay_distributions.account_code%TYPE,
        p_productcode             IN state_reqst_pay_distributions.product_code%TYPE,
        p_initiative              IN state_reqst_pay_distributions.initiative%TYPE,
        p_projectcode             IN state_reqst_pay_distributions.project_code%TYPE,
        p_ucsamount               IN state_reqst_pay_distributions.ucs_dollars%TYPE,
        p_ucspercent              IN state_reqst_pay_distributions.ucs_percent%TYPE,
        p_paydistributiontypeid   IN state_reqst_pay_distributions.paydistributiontypeid%TYPE);

    PROCEDURE get_usfpg_entities (curr_entities OUT SYS_REFCURSOR);

    PROCEDURE get_usfpg_hed_components (curr_hed_components OUT SYS_REFCURSOR);

    PROCEDURE get_pg_fund_request_deps (
        curr_request_types    OUT SYS_REFCURSOR,
        curr_hed_components   OUT SYS_REFCURSOR);

    PROCEDURE suggest_division (
        p_personid        IN     person_userroles_active.person_id%TYPE,
        p_keyglobaldept   IN     person_userroles_active.key_global_dept%TYPE,
        p_entitycode      IN     hsc.usfpg_dept_profile_mv.usfpg_dept_div_code%TYPE,
        p_context         IN     VARCHAR2,
        p_searchterm      IN     VARCHAR2,
        curr_results         OUT SYS_REFCURSOR);

    PROCEDURE del_pg_funds_requests (
        p_personid                IN person_userroles_active.person_id%TYPE,
        p_keyglobaldept           IN pg_funds_requests.key_global_dept%TYPE,
        p_csvpgfundsrequestsids   IN VARCHAR2);

    PROCEDURE cancel_pg_funds_requests (
        p_personid                IN person_userroles_active.person_id%TYPE,
        p_keyglobaldept           IN pg_funds_requests.key_global_dept%TYPE,
        p_csvpgfundsrequestsids   IN VARCHAR2);

    PROCEDURE upd_pg_funds_request (
        p_personid                IN person_userroles_active.person_id%TYPE,
        p_pgfundsrequestid        IN pg_funds_requests.pgfundsrequestid%TYPE,
        p_entity                  IN pg_funds_requests.entity%TYPE,
        p_divisioncode            IN pg_funds_requests.division_code%TYPE,
        p_employeeid              IN pg_funds_requests.employee_id%TYPE,
        p_lastname                IN pg_funds_requests.last_name%TYPE,
        p_firstname               IN pg_funds_requests.first_name%TYPE,
        p_status                  IN pg_funds_requests.status%TYPE,
        p_jobtitle                IN pg_funds_requests.job_title%TYPE,
        p_annualrate              IN pg_funds_requests.annual_rate%TYPE,
        p_annualtotal             IN pg_funds_requests.annual_total%TYPE,
        p_hiremonth               IN pg_funds_requests.hire_month%TYPE,
        p_typeid                  IN pg_funds_requests.pgfundsrequesttypeid%TYPE,
        p_justificationcomments   IN pg_funds_requests.justification_comments%TYPE);

    PROCEDURE ins_pg_funds_request (
        p_personid                IN     person_userroles_active.person_id%TYPE,
        p_keyglobaldept           IN     pg_funds_requests.key_global_dept%TYPE,
        p_entity                  IN     pg_funds_requests.entity%TYPE,
        p_divisioncode            IN     pg_funds_requests.division_code%TYPE,
        p_employeeid              IN     pg_funds_requests.employee_id%TYPE,
        p_lastname                IN     pg_funds_requests.last_name%TYPE,
        p_firstname               IN     pg_funds_requests.first_name%TYPE,
        p_status                  IN     pg_funds_requests.status%TYPE,
        p_jobtitle                IN     pg_funds_requests.job_title%TYPE,
        p_annualrate              IN     pg_funds_requests.annual_rate%TYPE,
        p_annualtotal             IN     pg_funds_requests.annual_total%TYPE,
        p_hiremonth               IN     pg_funds_requests.hire_month%TYPE,
        p_typeid                  IN     pg_funds_requests.pgfundsrequesttypeid%TYPE,
        p_justificationcomments   IN     pg_funds_requests.justification_comments%TYPE,
        p_fiscalyear              IN     pg_funds_requests.budget_fy%TYPE,
        r_pgfundsrequestid           OUT pg_funds_requests.pgfundsrequestid%TYPE);

    PROCEDURE save_pg_fund_request_component (
        p_pgfundsrequestcomponentid   IN pg_funds_request_components.pgfundsrequestcomponentid%TYPE,
        p_pgfundsrequestid            IN pg_funds_request_components.pgfundsrequestid%TYPE,
        p_deptdivcode                 IN pg_funds_request_components.dept_div_code%TYPE,
        p_divisioncode                IN pg_funds_request_components.division_code%TYPE,
        p_hedcode                     IN pg_funds_request_components.hed_code%TYPE,
        p_rate                        IN pg_funds_request_components.rate%TYPE,
        p_hours                       IN pg_funds_request_components.hours%TYPE,
        p_numpayperiods               IN pg_funds_request_components.num_pay_periods%TYPE,
        p_annualrate                  IN pg_funds_request_components.annual_rate%TYPE,
        p_taxes                       IN pg_funds_request_components.taxes%TYPE,
        p_benefits                    IN pg_funds_request_components.benefits%TYPE,
        p_retirement                  IN pg_funds_request_components.retirement%TYPE,
        p_deleteflag                  IN NUMBER);

    PROCEDURE save_pg_duplicate_distribution (
        p_personid                    IN person_userroles_active.person_id%TYPE,
        p_pgduplicatedistributionid   IN pg_duplicate_distributions.pgduplicatedistributionid%TYPE,
        p_keyglobaldept               IN person_userroles_active.key_global_dept%TYPE,
        p_employeenumber              IN pg_duplicate_distributions.employeenumber%TYPE,
        p_hednumber                   IN pg_duplicate_distributions.hed_number%TYPE,
        p_hourly_rate                 IN pg_duplicate_distributions.rate%TYPE,
        p_hours                       IN pg_duplicate_distributions.hours%TYPE,
        p_num_pay_periods             IN pg_duplicate_distributions.num_pay_periods%TYPE,
        p_annualrate                  IN pg_duplicate_distributions.annual_rate%TYPE,
        p_taxes                       IN pg_duplicate_distributions.taxes%TYPE,
        p_retirement                  IN pg_duplicate_distributions.retirement%TYPE,
        p_benefits                    IN pg_duplicate_distributions.benefits%TYPE,
        p_periodenddate               IN pg_duplicate_distributions.period_end_date%TYPE,
        p_entity                      IN pg_duplicate_distributions.entity%TYPE,
        p_departmentdivcode           IN pg_duplicate_distributions.dept_div_code%TYPE,
        p_divisioncode                IN pg_duplicate_distributions.division_code%TYPE,
        p_fiscalyear                  IN pg_duplicate_distributions.budget_fy%TYPE,
        p_q4_projected                IN pg_duplicate_distributions.q4_projected%TYPE,
        p_new_loss                    IN pg_duplicate_distributions.new_loss%TYPE);

    PROCEDURE del_pg_duplicate_distribution (
        p_personid        IN person_userroles_active.person_id%TYPE,
        p_keyglobaldept   IN person_userroles_active.key_global_dept%TYPE,
        p_csvids          IN VARCHAR2);

    PROCEDURE del_all_pg_duplicates (
        p_personid        IN person_userroles_active.person_id%TYPE,
        p_keyglobaldept   IN person_userroles_active.key_global_dept%TYPE,
        p_emplid          IN pg_duplicate_distributions.employeenumber%TYPE,
        p_fy              IN pg_duplicate_distributions.budget_fy%TYPE);

    PROCEDURE save_pg_refresh_date (
        p_personid        IN person_userroles_active.person_id%TYPE,
        p_emplid          IN pg_pay_distribution_dates.emplid%TYPE,
        p_keyglobaldept   IN pg_pay_distribution_dates.key_global_dept%TYPE,
        p_fiscalyear      IN pg_pay_distribution_dates.fy%TYPE,
        p_currentdate     IN pg_pay_distribution_dates.CURRENT_DATE%TYPE);

    PROCEDURE get_vacant_positions (
        p_personid        IN     person_userroles_active.person_id%TYPE,
        p_keyglobaldept   IN     vacant_positions.key_global_dept%TYPE,
        p_context         IN     VARCHAR2,
        p_fiscalyear      IN     vacant_positions.fy%TYPE,
        curr_vacant          OUT SYS_REFCURSOR);

    PROCEDURE del_vacant_positions (
        p_personid               IN person_userroles_active.person_id%TYPE,
        p_keyglobaldept          IN pg_pay_distribution_dates.key_global_dept%TYPE,
        p_csvvacantpositionids   IN VARCHAR2);

    PROCEDURE ins_vacant_position (
        p_personid            IN person_userroles_active.person_id%TYPE,
        p_keyglobaldept       IN vacant_positions.key_global_dept%TYPE,
        p_context             IN VARCHAR2,
        p_lastname            IN vacant_positions.last_name%TYPE,
        p_firstname           IN vacant_positions.first_name%TYPE,
        p_entity              IN vacant_positions.entity%TYPE,
        p_statefundsclassid   IN vacant_positions.statefundsclassid%TYPE,
        p_emplid              IN vacant_positions.emplid%TYPE,
        p_positionnumber      IN vacant_positions.position_number%TYPE,
        p_jobtitle            IN vacant_positions.job_title%TYPE,
        p_annualsalary        IN vacant_positions.annual_salary%TYPE,
        p_leavedate           IN vacant_positions.leave_date%TYPE,
        p_comments            IN vacant_positions.comments%TYPE,
        p_fiscalyear          IN vacant_positions.fy%TYPE);

    PROCEDURE upd_vacant_position (
        p_personid            IN person_userroles_active.person_id%TYPE,
        p_keyglobaldept       IN pg_pay_distribution_dates.key_global_dept%TYPE,
        p_context             IN VARCHAR2,
        p_vacantpositionid    IN vacant_positions.vacantpositionid%TYPE,
        p_lastname            IN vacant_positions.last_name%TYPE,
        p_firstname           IN vacant_positions.first_name%TYPE,
        p_entity              IN vacant_positions.entity%TYPE,
        p_statefundsclassid   IN vacant_positions.statefundsclassid%TYPE,
        p_emplid              IN vacant_positions.emplid%TYPE,
        p_positionnumber      IN vacant_positions.position_number%TYPE,
        p_jobtitle            IN vacant_positions.job_title%TYPE,
        p_annualsalary        IN vacant_positions.annual_salary%TYPE,
        p_leavedate           IN vacant_positions.leave_date%TYPE,
        p_comments            IN vacant_positions.comments%TYPE);

    PROCEDURE submit_state_rqsts_for_apprvl (
        p_personid        IN     person_userroles_active.person_id%TYPE,
        p_keyglobaldept   IN     state_funds_requests.key_global_dept%TYPE,
        p_fiscalyear      IN     state_funds_requests.budget_fy%TYPE,
        r_errors             OUT VARCHAR2);

    PROCEDURE cancel_state_funds_requests (
        p_personid                   IN person_userroles_active.person_id%TYPE,
        p_keyglobaldept              IN state_funds_requests.key_global_dept%TYPE,
        p_csvstatefundsrequestsids   IN VARCHAR2);

    PROCEDURE get_state_fund_rqst_hist (
        p_personid              IN     person_userroles_active.person_id%TYPE,
        p_statefundsrequestid   IN     state_funds_requests.statefundsrequestid%TYPE,
        curr_request_info          OUT SYS_REFCURSOR,
        curr_history               OUT SYS_REFCURSOR);

    PROCEDURE submit_pg_rqsts_for_apprvl (
        p_personid        IN     person_userroles_active.person_id%TYPE,
        p_keyglobaldept   IN     pg_funds_requests.key_global_dept%TYPE,
        p_fiscalyear      IN     pg_funds_requests.budget_fy%TYPE,
        r_errors             OUT VARCHAR2);

    PROCEDURE get_pg_fund_rqst_hist (
        p_personid           IN     person_userroles_active.person_id%TYPE,
        p_pgfundsrequestid   IN     pg_funds_requests.pgfundsrequestid%TYPE,
        curr_request_info       OUT SYS_REFCURSOR,
        curr_history            OUT SYS_REFCURSOR);

    PROCEDURE upd_state_fund_rqst_status (
        p_personid              IN person_userroles_active.person_id%TYPE,
        p_statefundsrequestid   IN state_funds_requests.statefundsrequestid%TYPE,
        p_fundrequeststatusid   IN state_funds_requests.fundrequeststatusid%TYPE,
        p_denialreason          IN state_funds_requests.denial_reason%TYPE);

    PROCEDURE upd_pg_fund_rqst_status (
        p_personid              IN person_userroles_active.person_id%TYPE,
        p_pgfundsrequestid      IN pg_funds_requests.pgfundsrequestid%TYPE,
        p_fundrequeststatusid   IN pg_funds_requests.fundrequeststatusid%TYPE,
        p_denialreason          IN pg_funds_requests.denial_reason%TYPE);

    PROCEDURE get_dept_fundproduct_totals (
        p_keyglobaldept   IN     hsc.usf_dept_profile_mv.key_global_dept%TYPE,
        p_fiscalyear      IN     funds.budget_fy%TYPE,
        r_totalfunds         OUT funds.amount%TYPE,
        curr_products        OUT SYS_REFCURSOR,
        curr_funds           OUT SYS_REFCURSOR);

    PROCEDURE get_college_codes (
        p_personid      IN     hsc.sd_hsc_directory.person_id%TYPE,
        curr_colleges      OUT SYS_REFCURSOR);

    PROCEDURE get_college_control (
        p_fiscalyear    IN     college_fund.budget_fy%TYPE,
        curr_colleges      OUT SYS_REFCURSOR);

    PROCEDURE del_department_locks (
        p_personid        IN person_userroles_active.person_id%TYPE,
        p_keyglobaldept   IN department_locks.key_global_dept%TYPE,
        p_startdate       IN department_locks.start_date%TYPE,
        p_enddate         IN department_locks.end_date%TYPE);

    PROCEDURE ins_department_locks (
        p_personid            IN person_userroles_active.person_id%TYPE,
        p_csvkeyglobaldepts   IN VARCHAR2,
        p_startdate           IN department_locks.start_date%TYPE,
        p_enddate             IN department_locks.end_date%TYPE);

    PROCEDURE get_department_locks (curr_departments OUT SYS_REFCURSOR);

    PROCEDURE get_college_funds (
        p_personid      IN     person_userroles_active.person_id%TYPE,
        p_collegecode   IN     college_fund.college_code%TYPE,
        p_fiscalyear    IN     college_fund.budget_fy%TYPE,
        curr_funds         OUT SYS_REFCURSOR);

    PROCEDURE del_college_funds (
        p_personid            IN person_userroles_active.person_id%TYPE,
        p_collegecode         IN college_fund.college_code%TYPE,
        p_csvcollegefundids   IN VARCHAR2);

    PROCEDURE ins_college_fund (
        p_personid          IN person_userroles_active.person_id%TYPE,
        p_collegecode       IN college_fund.college_code%TYPE,
        p_name              IN college_fund.name%TYPE,
        p_chartfield        IN college_fund.chartfield%TYPE,
        p_amount            IN college_fund.amount%TYPE,
        p_facultyamount     IN college_fund.faculty_amount%TYPE,
        p_staffamount       IN college_fund.staff_amount%TYPE,
        p_nonsalaryamount   IN college_fund.nonsalary_amount%TYPE,
        p_effectivedate     IN college_fund.effective_date%TYPE,
        p_fiscalyear        IN college_fund.budget_fy%TYPE);

    PROCEDURE upd_college_fund (
        p_personid          IN person_userroles_active.person_id%TYPE,
        p_collegecode       IN college_fund.college_code%TYPE,
        p_collegefundid     IN college_fund.collegefundid%TYPE,
        p_name              IN college_fund.name%TYPE,
        p_chartfield        IN college_fund.chartfield%TYPE,
        p_amount            IN college_fund.amount%TYPE,
        p_facultyamount     IN college_fund.faculty_amount%TYPE,
        p_staffamount       IN college_fund.staff_amount%TYPE,
        p_nonsalaryamount   IN college_fund.nonsalary_amount%TYPE,
        p_effectivedate     IN college_fund.effective_date%TYPE);

    PROCEDURE get_fiscal_years (curr_fys OUT SYS_REFCURSOR);

    PROCEDURE sel_persons (p_q         IN     hsc.sd_hsc_directory.first_name%TYPE,
                           p_persons   IN OUT SYS_REFCURSOR);

    PROCEDURE get_schedule_data (
        p_usfdeptcode          IN     schedule.usf_dept_code%TYPE,
        p_scheduletype         IN     schedule_type_lk.schedule_type_id%TYPE,
        p_budgetfy             IN     schedule.fiscal_year%TYPE,
        p_fundcode             IN     schedule.fund_code%TYPE,
        curr_schedule             OUT SYS_REFCURSOR,
        curr_col_config           OUT SYS_REFCURSOR,
        curr_groupcodes           OUT SYS_REFCURSOR,
        curr_type_data            OUT SYS_REFCURSOR,
        curr_item_configs         OUT SYS_REFCURSOR,
        curr_items                OUT SYS_REFCURSOR,
        curr_personnel_data       OUT SYS_REFCURSOR,
        curr_control_numbers      OUT SYS_REFCURSOR,
        curr_base_budget          OUT SYS_REFCURSOR,
        curr_reductions           OUT SYS_REFCURSOR);

    PROCEDURE sel_curr_personnel_data (
        p_key_global_dept      IN     hsc.usf_dept_profile_mv.key_global_dept%TYPE,
        p_scheduletype         IN     schedule_type_lk.schedule_type_id%TYPE,
        p_budgetfy             IN     schedule.fiscal_year%TYPE,
        curr_personnel_data       OUT SYS_REFCURSOR
    );

    PROCEDURE get_all_schedule_data (
        p_key_global_dept      IN     hsc.usf_dept_profile_mv.key_global_dept%TYPE,
        p_scheduletype         IN     schedule_type_lk.schedule_type_id%TYPE,
        p_budgetfy             IN     schedule.fiscal_year%TYPE,
        curr_schedule             OUT SYS_REFCURSOR,
        curr_col_config           OUT SYS_REFCURSOR,
        curr_groupcodes           OUT SYS_REFCURSOR,
        curr_type_data            OUT SYS_REFCURSOR,
        curr_item_configs         OUT SYS_REFCURSOR,
        curr_items                OUT SYS_REFCURSOR,
        curr_personnel_data       OUT SYS_REFCURSOR,
        curr_control_numbers      OUT SYS_REFCURSOR,
        curr_base_budget          OUT SYS_REFCURSOR,
        curr_reductions           OUT SYS_REFCURSOR,
        curr_sfr_data             OUT SYS_REFCURSOR);

    PROCEDURE get_schedule_types (
      p_fiscal_year schedule_type_component_lk.fy_start%type,
      curr_types OUT SYS_REFCURSOR);

    PROCEDURE ins_upd_schedule_data_h_g (
        p_scheduleid               IN schedule_data_h_g.schedule_id%TYPE,
        p_productcode              IN schedule_data_h_g.product_code%TYPE,
        p_req_initiative           IN schedule_data_h_g.req_initiative%TYPE,
        p_req_comment              IN schedule_data_h_g.req_comment%TYPE,
        p_proj_initiative          IN schedule_data_h_g.proj_initiative%TYPE,
        p_proj_comment             IN schedule_data_h_g.proj_comment%TYPE,
        p_req_py_remaining_reqs    IN schedule_data_h_g.req_py_remaining_reqs%TYPE,
        p_req_new_reqs             IN schedule_data_h_g.req_new_reqs%TYPE,
        p_proj_new_reqs            IN schedule_data_h_g.proj_new_reqs%TYPE,
        p_proj_py_remaining_reqs   IN schedule_data_h_g.proj_py_remaining_reqs%TYPE);

    PROCEDURE ins_upd_schedule_data_h_g_new (
        p_scheduleid               IN schedule_data_h_g.schedule_id%TYPE,
        p_productcode              IN schedule_data_h_g.product_code%TYPE,
        p_req_initiative           IN schedule_data_h_g.req_initiative%TYPE,
        p_req_comment              IN schedule_data_h_g.req_comment%TYPE,
        p_proj_initiative          IN schedule_data_h_g.proj_initiative%TYPE,
        p_proj_comment             IN schedule_data_h_g.proj_comment%TYPE,
        p_req_py_remaining_reqs    IN schedule_data_h_g.req_py_remaining_reqs%TYPE,
        p_req_new_reqs             IN schedule_data_h_g.req_new_reqs%TYPE,
        p_proj_new_reqs            IN schedule_data_h_g.proj_new_reqs%TYPE,
        p_proj_py_remaining_reqs   IN schedule_data_h_g.proj_py_remaining_reqs%TYPE);

    PROCEDURE ins_upd_schedule_item (
        p_scheduleid          IN schedule_item.schedule_id%TYPE,
        p_budgetcode          IN schedule_item.budget_code%TYPE,
        p_oco_number          IN schedule_item.oco_number%TYPE,
        p_productcode         IN schedule_item.product_code%TYPE,
        p_actual              IN schedule_item.actual%TYPE,
        p_projected           IN schedule_item.projected%TYPE,
        p_customdescription   IN schedule_item_config.custom_desc%TYPE);

    PROCEDURE ins_upd_schedule_item_new (
        p_scheduleid          IN schedule_item.schedule_id%TYPE,
        p_budgetcode          IN schedule_item.budget_code%TYPE,
        p_oco_number          IN schedule_item.oco_number%TYPE,
        p_productcode         IN schedule_item.product_code%TYPE,
        p_actual              IN schedule_item.actual%TYPE,
        p_projected           IN schedule_item.projected%TYPE,
        p_customdescription   IN schedule_item_config.custom_desc%TYPE,
        p_initiative_code     IN schedule_item.initiative_code%TYPE,
        p_key_global_dept     IN schedule_item_config_dept.key_global_dept%TYPE,
        p_fiscal_year         IN schedule_item_config_dept.fiscal_year%TYPE,
        p_schedule_type_id    IN schedule_item_config_dept.schedule_type_id%TYPE);

    PROCEDURE del_blank_schedule_item (
        p_key_global_dept   IN person_userroles_active.key_global_dept%TYPE,
        p_fiscal_year IN schedule.fiscal_year%type,
        p_schedule_type_id IN schedule.schedule_type_id%type
      );

    PROCEDURE del_schedule_product (
        p_personid        IN person_userroles_active.person_id%TYPE,
        p_keyglobaldept   IN person_userroles_active.key_global_dept%TYPE,
        p_scheduleid      IN schedule_item.schedule_id%TYPE,
        p_productcode     IN schedule_item.product_code%TYPE);



    PROCEDURE del_schedule_product_new (
        p_personid         IN person_userroles_active.person_id%TYPE,
        p_keyglobaldept    IN person_userroles_active.key_global_dept%TYPE,
        p_scheduleid       IN schedule_item.schedule_id%TYPE,
        p_productcode      IN schedule_item.product_code%TYPE,
        p_initiativecode   IN schedule_data_h_g.req_initiative%TYPE);

    PROCEDURE del_schedule_budgetcode (
        p_personid        IN person_userroles_active.person_id%TYPE,
        p_keyglobaldept   IN person_userroles_active.key_global_dept%TYPE,
        p_scheduleid      IN schedule_item.schedule_id%TYPE,
        p_budgetcode      IN schedule_item.budget_code%TYPE,
        p_oco_number      IN schedule_item.oco_number%TYPE);

    PROCEDURE del_schedule_budgetcode_new (
        p_personid          IN person_userroles_active.person_id%TYPE,
        p_key_global_dept   IN person_userroles_active.key_global_dept%TYPE,
        p_scheduletypeid    IN schedule.schedule_type_id%TYPE,
        p_budgetcode        IN schedule_item.budget_code%TYPE,
        p_oco_number        IN schedule_item.oco_number%TYPE,
        p_fiscal_year       IN schedule.fiscal_year%TYPE);

    PROCEDURE get_fund_codes_internal (curr_codes OUT SYS_REFCURSOR);

    PROCEDURE upd_schedule_base_red_pcnt (
        p_scheduleid   IN schedule.schedule_id%TYPE,
        p_pcnt         IN schedule.base_reduction_pcnt%TYPE);

    PROCEDURE sel_suggest_product (p_search        IN     VARCHAR2,
                                   curr_products      OUT SYS_REFCURSOR);

    PROCEDURE set_schedule_base_red_pcnt (
        p_key_global_dept   IN schedule_base_reduction.key_global_dept%TYPE,
        p_budget_fy         IN schedule_base_reduction.fiscal_year%TYPE,
        p_pcnt              IN schedule_base_reduction.base_reduction_pcnt%TYPE);

    PROCEDURE ins_upd_schedule_data_g (
        p_scheduleid      IN schedule_data_g.schedule_id%TYPE,
        p_productcode     IN schedule_data_g.product_code%TYPE,
        p_facultyrate     IN schedule_data_g.proj_faculty_rate%TYPE,
        p_staffrate       IN schedule_data_g.proj_staff_rate%TYPE,
        p_nonsalaryrate   IN schedule_data_g.proj_nonsalary_rate%TYPE);

    PROCEDURE ins_upd_schedule_data_g_new (
        p_scheduleid        IN schedule_data_g.schedule_id%TYPE,
        p_productcode       IN schedule_data_g.product_code%TYPE,
        p_facultyrate       IN schedule_data_g.proj_faculty_rate%TYPE,
        p_staffrate         IN schedule_data_g.proj_staff_rate%TYPE,
        p_nonsalaryrate     IN schedule_data_g.proj_nonsalary_rate%TYPE,
        p_initiative_code   IN schedule_data_g.initiative_code%TYPE);

    PROCEDURE get_control_check_data (
        p_budgetfy            IN     fiscal_year.budget_fy%TYPE,
        p_keyglobaldept       IN     hsc.usf_dept_profile_mv.key_global_dept%TYPE,
        p_csvexcludeemplids   IN     VARCHAR2,
        curr_data                OUT SYS_REFCURSOR);

    PROCEDURE upd_apprvd_cncld_rqst_cntrl (
        p_statefundsrequestid   IN state_funds_requests.statefundsrequestid%TYPE,
        p_context               IN VARCHAR2    /* A --approved, C --canceled*/
                                           );

    PROCEDURE get_schedule_ria_data (
        p_usfdeptcode           IN     schedule.usf_dept_code%TYPE,
        p_budgetfy              IN     schedule.fiscal_year%TYPE,
        curr_schedule              OUT SYS_REFCURSOR,
        curr_initiatives           OUT SYS_REFCURSOR,
        curr_initiative_funds      OUT SYS_REFCURSOR,
        curr_item_configs          OUT SYS_REFCURSOR,
        curr_items                 OUT SYS_REFCURSOR,
        curr_personnel_data        OUT SYS_REFCURSOR,
        curr_groupcodes            OUT SYS_REFCURSOR,
        curr_sfr_data              OUT SYS_REFCURSOR);

    PROCEDURE ins_schedule_j_initiative (
        p_schedule_id                IN     schedule_j_initiative.schedule_id%TYPE,
        p_initiative_rfrn            IN     schedule_j_initiative.initiative_rfrn%TYPE,
        p_pi_name                    IN     schedule_j_initiative.pi_name%TYPE,
        p_comment                    IN     schedule_j_initiative.commnt%TYPE,
        r_schedule_j_initiative_id      OUT schedule_j_initiative.schedule_j_initiative_id%TYPE);

    PROCEDURE upd_schedule_j_initiative (
        p_schedule_j_initiative_id   IN schedule_j_initiative.schedule_j_initiative_id%TYPE,
        p_initiative_rfrn            IN schedule_j_initiative.initiative_rfrn%TYPE,
        p_pi_name                    IN schedule_j_initiative.pi_name%TYPE,
        p_comment                    IN schedule_j_initiative.commnt%TYPE);

    PROCEDURE set_schedule_j_initiative_fund (
        p_schedule_j_initiative_id   IN schedule_j_initiative_fund.schedule_j_initiative_id%TYPE,
        p_original_fund_code         IN schedule_j_initiative_fund.fund_code%TYPE,
        p_fund_code                  IN schedule_j_initiative_fund.fund_code%TYPE,
        p_estimated_june_budget      IN schedule_j_initiative_fund.estimated_june_budget%TYPE,
        p_estimated_fund_alloc       IN schedule_j_initiative_fund.estimated_fund_alloc%TYPE);

    PROCEDURE set_schedule_j_item (
        p_budget_code                IN schedule_j_item.budget_code%TYPE,
        p_oco_number                 IN schedule_j_item.oco_number%TYPE,
        p_schedule_j_initiative_id   IN schedule_j_item.schedule_j_initiative_id%TYPE,
        p_fund_code                  IN schedule_j_item.fund_code%TYPE,
        p_amount                     IN schedule_j_item.amount%TYPE);

    PROCEDURE del_schedule_j_initiative_fund (
        p_person_id                  IN person_userroles_active.person_id%TYPE,
        p_key_global_dept            IN person_userroles_active.key_global_dept%TYPE,
        p_schedule_j_initiative_id   IN schedule_j_initiative_fund.schedule_j_initiative_id%TYPE,
        p_fund_code                  IN schedule_j_initiative_fund.fund_code%TYPE);

    PROCEDURE del_schedule_j_initiative (
        p_person_id                  IN person_userroles_active.person_id%TYPE,
        p_key_global_dept            IN person_userroles_active.key_global_dept%TYPE,
        p_schedule_j_initiative_id   IN schedule_j_initiative_fund.schedule_j_initiative_id%TYPE);

    PROCEDURE del_schedule_j_budgetcode (
        p_person_id         IN person_userroles_active.person_id%TYPE,
        p_key_global_dept   IN person_userroles_active.key_global_dept%TYPE,
        p_schedule_id       IN schedule.schedule_id%TYPE,
        p_budget_code       IN schedule_j_item.budget_code%TYPE,
        p_oco_number        IN schedule_j_item.oco_number%TYPE);

    PROCEDURE set_schedule_custom_oco (
        p_schedule_id   IN schedule_item_config.schedule_id%TYPE,
        p_budget_code   IN schedule_item_config.budget_code%TYPE,
        p_oco_number    IN schedule_item_config.oco_number%TYPE,
        p_custom_desc   IN schedule_item_config.custom_desc%TYPE);

    PROCEDURE get_schedule_e_data (
        p_schedule_type_id    IN     schedule.schedule_type_id%TYPE,
        p_usfdeptcode         IN     schedule.usf_dept_code%TYPE,
        p_budgetfy            IN     schedule.fiscal_year%TYPE,
        curr_schedule            OUT SYS_REFCURSOR,
        curr_fund_groups         OUT SYS_REFCURSOR,
        curr_item_configs        OUT SYS_REFCURSOR,
        curr_items               OUT SYS_REFCURSOR,
        curr_personnel_data      OUT SYS_REFCURSOR,
        curr_groupcodes          OUT SYS_REFCURSOR);
      

    PROCEDURE ins_schedule_e_fund_group (
        p_schedule_id                  IN     schedule_e_fund_group.schedule_id%TYPE,
        p_fund_name                    IN     schedule_e_fund_group.fund_name%TYPE,
        p_undistributed_fund_code      IN     schedule_e_fund_group.undistributed_fund_code%TYPE,
        p_distributed_fund_code        IN     schedule_e_fund_group.distributed_fund_code%TYPE,
        p_convenience_fund_code        IN     schedule_e_fund_group.convenience_fund_code%TYPE,
        p_undistributed_june_balance   IN     schedule_e_fund_group.undistributed_june_balance%TYPE,
        p_distributed_june_balance     IN     schedule_e_fund_group.distributed_june_balance%TYPE,
        p_convenience_june_balance     IN     schedule_e_fund_group.convenience_june_balance%TYPE,
        p_endowment_interest           IN     schedule_e_fund_group.endowment_interest%TYPE,
        p_gifts_other_revenue          IN     schedule_e_fund_group.gifts_other_revenue%TYPE,
        p_trans_distrib_earnings       IN     schedule_e_fund_group.trans_distrib_earnings%TYPE,
        p_conv_trans_grnt_slries       IN     schedule_e_fund_group.convenience_trans_grnt_slries%TYPE,
        p_distrib_trans_grnt_slries    IN     schedule_e_fund_group.distrib_trans_grnt_slries%TYPE,
        p_trans_other_foundation       IN     schedule_e_fund_group.trans_other_foundation%TYPE,
        r_schedule_e_fund_group_id        OUT schedule_e_fund_group.schedule_e_fund_group_id%TYPE);

    PROCEDURE upd_schedule_e_fund_group (
        p_schedule_e_fund_group_id     IN schedule_e_fund_group.schedule_e_fund_group_id%TYPE,
        p_fund_name                    IN schedule_e_fund_group.fund_name%TYPE,
        p_undistributed_fund_code      IN schedule_e_fund_group.undistributed_fund_code%TYPE,
        p_distributed_fund_code        IN schedule_e_fund_group.distributed_fund_code%TYPE,
        p_convenience_fund_code        IN schedule_e_fund_group.convenience_fund_code%TYPE,
        p_undistributed_june_balance   IN schedule_e_fund_group.undistributed_june_balance%TYPE,
        p_distributed_june_balance     IN schedule_e_fund_group.distributed_june_balance%TYPE,
        p_convenience_june_balance     IN schedule_e_fund_group.convenience_june_balance%TYPE,
        p_endowment_interest           IN schedule_e_fund_group.endowment_interest%TYPE,
        p_gifts_other_revenue          IN schedule_e_fund_group.gifts_other_revenue%TYPE,
        p_trans_distrib_earnings       IN schedule_e_fund_group.trans_distrib_earnings%TYPE,
        p_conv_trans_grnt_slries       IN schedule_e_fund_group.convenience_trans_grnt_slries%TYPE,
        p_distrib_trans_grnt_slries    IN schedule_e_fund_group.distrib_trans_grnt_slries%TYPE,
        p_trans_other_foundation       IN schedule_e_fund_group.trans_other_foundation%TYPE);

    PROCEDURE ins_upd_schedule_e_item (
        p_schedule_e_fund_group_id   IN schedule_e_item.schedule_e_fund_group_id%TYPE,
        p_budget_code                IN schedule_e_item.budget_code%TYPE,
        p_oco_number                 IN schedule_e_item.oco_number%TYPE,
        p_amount_one                 IN schedule_e_item.amount_one%TYPE,
        p_amount_two                 IN schedule_e_item.amount_two%TYPE,
        p_amount_three               IN schedule_e_item.amount_three%TYPE);

    PROCEDURE del_schedule_e_budgetcode (
        p_person_id         IN person_userroles_active.person_id%TYPE,
        p_key_global_dept   IN person_userroles_active.key_global_dept%TYPE,
        p_schedule_id       IN schedule_e_fund_group.schedule_id%TYPE,
        p_budget_code       IN schedule_e_item.budget_code%TYPE,
        p_oco_number        IN schedule_e_item.oco_number%TYPE);

    PROCEDURE del_schedule_e_fund_group (
        p_person_id                  IN person_userroles_active.person_id%TYPE,
        p_key_global_dept            IN person_userroles_active.key_global_dept%TYPE,
        p_schedule_e_fund_group_id   IN schedule_e_fund_group.schedule_e_fund_group_id%TYPE);

    PROCEDURE get_schedule_l_data (
        p_dept_code           IN     schedule.usf_dept_code%TYPE,
        p_budget_fy           IN     schedule.fiscal_year%TYPE,
        curr_schedule            OUT SYS_REFCURSOR,
        curr_schedule_lines      OUT SYS_REFCURSOR);
        
    PROCEDURE get_new_schedule_l_data (
        p_dept_code           IN     schedule.usf_dept_code%TYPE,
        p_budget_fy           IN     schedule.fiscal_year%TYPE,
        curr_schedule            OUT SYS_REFCURSOR,
        curr_schedule_lines      OUT SYS_REFCURSOR);

    PROCEDURE ins_upd_schedule_data_l (
        p_schedule_data_l_id          IN schedule_data_l.schedule_data_l_id%TYPE,
        p_schedule_id                 IN schedule_data_l.schedule_id%TYPE,
        p_sponsor                     IN schedule_data_l.sponsor%TYPE,
        p_project_title               IN schedule_data_l.project_title%TYPE,
        p_pi_name                     IN schedule_data_l.pi_name%TYPE,
        p_award_start                 IN schedule_data_l.award_start%TYPE,
        p_award_end                   IN schedule_data_l.award_end%TYPE,
        p_budget_start                IN schedule_data_l.budget_start%TYPE,
        p_budget_end                  IN schedule_data_l.budget_end%TYPE,
        p_fund                        IN schedule_data_l.fund%TYPE,
        p_project                     IN schedule_data_l.project%TYPE,
        p_anticipated_end             IN schedule_data_l.anticipated_end%TYPE,
        p_estimated_residual_amount   IN schedule_data_l.estimated_residual_amount%TYPE,
        p_estimated_total_earnings    IN schedule_data_l.estimated_total_earnings%TYPE,
        p_idc_pcnt                    IN schedule_data_l.idc_pcnt%TYPE,
        p_salary_fringe               IN schedule_data_l.salary_fringe%TYPE,
        p_non_salary_expenditures     IN schedule_data_l.non_salary_expenditures%TYPE);

    PROCEDURE del_schedule_data_l_lines (
        p_csv_schedule_data_l_ids IN VARCHAR2);

    PROCEDURE get_schedule_i_combinations (
        p_key_global_dept   IN     hsc.hart_global_depts_mv.key_global_dept%TYPE,
        p_budget_fy         IN     schedule_i.fiscal_year%TYPE,
        curr_combinations      OUT SYS_REFCURSOR);

    PROCEDURE get_schedule_i_data (
        p_key_global_dept            IN     hsc.hart_global_depts_mv.key_global_dept%TYPE,
        p_dept_code                  IN     schedule_i.usf_dept_code%TYPE,
        p_fund_code                  IN     schedule_i.fund_code%TYPE,
        p_product_code               IN     schedule_i.product_code%TYPE,
        p_initiative                 IN     schedule_i.initiative%TYPE,
        p_budget_fy                  IN     schedule_i.fiscal_year%TYPE,
        curr_schedule                   OUT SYS_REFCURSOR,
        curr_budget_actuals             OUT SYS_REFCURSOR,
        curr_budget_requests            OUT SYS_REFCURSOR,
        curr_budget_requests_items      OUT SYS_REFCURSOR,
        curr_item_configs               OUT SYS_REFCURSOR,
        curr_budget_codes               OUT SYS_REFCURSOR,
        curr_personnel_data             OUT SYS_REFCURSOR,
        curr_grand_totals               OUT SYS_REFCURSOR);


    PROCEDURE upd_schedule_i (
        p_schedule_i_id      IN schedule_i.schedule_i_id%TYPE,
        p_fund_name          IN schedule_i.fund_name%TYPE,
        p_projected_budget   IN schedule_i.projected_budget%TYPE,
        p_justification      IN schedule_i.justification%TYPE);

    PROCEDURE ins_upd_schedule_i_bud_act (
        p_schedule_i_id   IN schedule_i_bud_act.schedule_i_id%TYPE,
        p_budget_code     IN schedule_i_bud_act.budget_code%TYPE,
        p_budget          IN schedule_i_bud_act.budget%TYPE,
        p_actuals         IN schedule_i_bud_act.actuals%TYPE,
        p_projected       IN schedule_i_bud_act.projected%TYPE);

    PROCEDURE ins_upd_schedule_i_bd_rqst_itm (
        p_schedule_i_id    IN schedule_i_bud_reqst_item.schedule_i_id%TYPE,
        p_product_code     IN schedule_i_bud_reqst_item.product_code%TYPE,
        p_admin_overhead   IN schedule_i_bud_reqst_item.admin_overhead%TYPE);

    PROCEDURE ins_upd_schedule_i_bud_reqst (
        p_schedule_i_id   IN schedule_i_bud_reqst.schedule_i_id%TYPE,
        p_budget_code     IN schedule_i_bud_reqst.budget_code%TYPE,
        p_amount          IN schedule_i_bud_reqst.amount%TYPE,
        p_product_code    IN schedule_i_bud_reqst.product_code%TYPE);

    PROCEDURE del_schedule_i_bud_reqst_prod (
        p_person_id         IN person_userroles_active.person_id%TYPE,
        p_key_global_dept   IN person_userroles_active.key_global_dept%TYPE,
        p_schedule_i_id     IN schedule_i_bud_reqst.schedule_i_id%TYPE,
        p_product_code      IN schedule_i_bud_reqst.product_code%TYPE);

    procedure del_schedule_i_combination(
        p_schedule_i_id in schedule_i.schedule_i_id%type
    );

    PROCEDURE set_schedule_g_reduction_new (
        p_schedule_id       IN schedule_g_reduction.schedule_id%TYPE,
        p_product_code      IN schedule_g_reduction.product_code%TYPE,
        p_amount            IN schedule_g_reduction.amount%TYPE,
        p_initiative_code   IN schedule_g_reduction.initiative_code%TYPE);


    PROCEDURE ins_upd_schedule_g_reduction (
        p_schedule_id    IN schedule_g_reduction.schedule_id%TYPE,
        p_product_code   IN schedule_g_reduction.product_code%TYPE,
        p_amount         IN schedule_g_reduction.amount%TYPE);

    PROCEDURE get_sched_i_grand_totals (
        p_key_global_dept   IN     hsc.usf_dept_profile_mv.key_global_dept%TYPE,
        p_fund_code         IN     schedule_i.fund_code%TYPE,
        p_budget_fy         IN     schedule_i.fiscal_year%TYPE,
        curr_totals            OUT SYS_REFCURSOR);

    PROCEDURE clean_up_userroles;

    FUNCTION f_pay_date_by_emp (p_emplid fast_pay_actuals.emplid%TYPE)
        RETURN DATE;

    FUNCTION f_pay_date_by_all
        RETURN DATE;

    FUNCTION f_pay_date_by_str
        RETURN VARCHAR2;

    FUNCTION f_get_home_dept (-- p_emplid fast_pay_actuals.emplid%TYPE,
                              p_deptid gems_job_data.deptid%TYPE)
        RETURN NUMBER;

    FUNCTION f_fast_to_global (p_deptid fast_pay_actuals.deptid%TYPE)
        RETURN NUMBER;



    PROCEDURE get_pay_date_by_all (
        p_max_date OUT fast_pay_actuals.pay_date%TYPE);

    PROCEDURE get_gems_list_data (
        p_person_id         IN     hsc.sd_hsc_directory.person_id%TYPE,
        p_key_global_dept   IN     NUMBER,
        p_order             IN     VARCHAR2,
        p_type              IN     VARCHAR2,
        p_currentfy         IN     VARCHAR2,
        p_rc                   OUT VARCHAR2,
        p_csr               IN OUT SYS_REFCURSOR);


    PROCEDURE sel_gems_list_data (
        p_person_id         IN     hsc.sd_hsc_directory.person_id%TYPE,
        p_key_global_dept   IN     NUMBER,
        p_order             IN     VARCHAR2,
        p_type              IN     VARCHAR2,
        p_currentfy         IN     VARCHAR2,
        p_columnslist       IN     VARCHAR2 DEFAULT '',
        p_emplid            IN     VARCHAR2,
        p_rc                   OUT VARCHAR2,
        p_csr               IN OUT SYS_REFCURSOR);

    /*
    PROCEDURE get_gems_job_data
       (
           p_person_id       IN hsc.sd_hsc_directory.person_id%TYPE,
           p_key_global_dept IN NUMBER,
           p_emplid          IN gems_job_data.emplid%TYPE,
           p_csr             IN OUT   SYS_REFCURSOR
       );
       */

    PROCEDURE get_gems_comp_rates (
        p_emplid     IN     gems_job_data.emplid%TYPE,
        p_empl_rcd   IN     gems_job_data.empl_rcd%TYPE,
        p_csr        IN OUT SYS_REFCURSOR);

    PROCEDURE get_gems_person_detail (
        p_person_id         IN     person_userroles_active.person_id%TYPE,
        p_key_global_dept   IN     NUMBER,
        p_emp_type          IN     VARCHAR2,
        p_current_fy        IN     fiscal_year.fy%TYPE,
        p_emplid            IN     gems_job_data.emplid%TYPE,
        p_csr               IN OUT SYS_REFCURSOR);

    PROCEDURE get_gems_rec_person_detail (
        p_emplid    IN     gems_job_data.emplid%TYPE,
        p_emp_rec   IN     gems_job_data.empl_rcd%TYPE,
        p_csr       IN OUT SYS_REFCURSOR);

    PROCEDURE get_pay_distribution_dates (
        p_emplid            IN     fast_pay_actuals.emplid%TYPE,
        p_fy                IN     pay_distribution_dates.fy%TYPE,
        p_key_global_dept   IN     pay_distribution_dates.key_global_dept%TYPE,
        p_empl_rcd          IN     pay_distribution_dates.empl_rcd%TYPE,
        p_csr               IN OUT SYS_REFCURSOR);

    PROCEDURE upd_pay_distribution_dates (
        p_emplid            IN pay_distribution_dates.emplid%TYPE,
        p_fy                IN pay_distribution_dates.fy%TYPE,
        p_view_date         IN pay_distribution_dates.view_date%TYPE,
        p_key_global_dept   IN pay_distribution_dates.key_global_dept%TYPE,
        p_empl_rcd          IN pay_distribution_dates.empl_rcd%TYPE);

    PROCEDURE upd_pay_distribution_dept (
        p_key_global_dept   IN pay_distribution_dates.key_global_dept%TYPE,
        p_next_fy           IN pay_distribution_dates.fy%TYPE,
        p_emp_type          IN salary_admin_plan_code.emp_type%TYPE,
        p_view_date         IN pay_distribution_dates.view_date%TYPE);


    PROCEDURE get_fast_pay_data (
        p_emplid       IN     fast_pay_actuals.emplid%TYPE,
        p_pay_date     IN     fast_pay_actuals.pay_date%TYPE,
        p_annual_pay   IN     gems_job_data.pay_rt_annual%TYPE,
        p_sum             OUT fast_pay_actuals.actual_amt%TYPE,
        p_csr          IN OUT SYS_REFCURSOR);

    PROCEDURE get_fast_pay_data_by_home (
        p_emplid            IN     fast_pay_actuals.emplid%TYPE,
        p_pay_date          IN     fast_pay_actuals.pay_date%TYPE,
        p_annual_pay        IN     gems_job_data.pay_rt_annual%TYPE,
        p_key_global_dept   IN     NUMBER,
        p_sum                  OUT fast_pay_actuals.actual_amt%TYPE,
        p_csr               IN OUT SYS_REFCURSOR);



    PROCEDURE get_fast_pay_data_by_home_all (
        p_csvemplid         IN     VARCHAR2,
        p_pay_date          IN     fast_pay_actuals.pay_date%TYPE,
        p_annual_pay        IN     gems_job_data.pay_rt_annual%TYPE,
        p_key_global_dept   IN     NUMBER,
        p_budgetfy          IN     pay_distribution_dates.fy%TYPE,
        p_csr                  OUT SYS_REFCURSOR);

    PROCEDURE dup_dept_fast_pay_data (
        p_personid          IN person_userroles_active.person_id%TYPE,
        p_key_global_dept   IN NUMBER,
        p_employeetype      IN VARCHAR2,
        p_fy                IN VARCHAR,
        p_baseviewdate      IN pay_distribution_dates.view_date%TYPE);

    PROCEDURE dup_fast_pay_data (
        p_emplid            IN     future_dist.emplid%TYPE,
        p_fy                IN     future_dist.fy%TYPE,
        p_key_global_dept   IN     NUMBER,
        p_annual_pay        IN     gems_job_data.pay_rt_annual%TYPE,
        p_pay_date          IN     fast_pay_actuals.pay_date%TYPE,
        p_emp_type          IN     VARCHAR2,
        p_write_flag        IN     NUMBER,
        p_person_id         IN     person_userroles_active.person_id%TYPE,
        p_empl_rcd          IN     future_dist.empl_rcd%TYPE,
        p_sum                  OUT fast_pay_actuals.actual_amt%TYPE,
        p_csr               IN OUT SYS_REFCURSOR);

    PROCEDURE dup_fast_pay_data_internal (
        p_emplid            IN     future_dist.emplid%TYPE,
        p_fy                IN     future_dist.fy%TYPE,
        p_key_global_dept   IN     NUMBER,
        p_annual_pay        IN     gems_job_data.pay_rt_annual%TYPE,
        p_pay_date          IN     fast_pay_actuals.pay_date%TYPE,
        p_emp_type          IN     VARCHAR2,
        p_write_flag        IN     NUMBER,
        p_read_back_flag    IN     NUMBER,
        p_person_id         IN     person_userroles_active.person_id%TYPE,
        p_empl_rcd          IN     future_dist.empl_rcd%TYPE,
        p_sum                  OUT fast_pay_actuals.actual_amt%TYPE,
        p_csr               IN OUT SYS_REFCURSOR);

     procedure sel_future_dists(
        p_emplid            IN     future_dist.emplid%TYPE,
        p_fy                IN     future_dist.fy%TYPE,
        p_empl_rcd          IN     future_dist.empl_rcd%TYPE,
--        p_sum                  OUT fast_pay_actuals.actual_amt%TYPE,
        p_csr               IN OUT SYS_REFCURSOR);

    PROCEDURE get_future_dist (
        p_emplid         IN     future_dist.emplid%TYPE,
        p_fy             IN     future_dist.fy%TYPE,
        p_sharing_flag   IN     NUMBER DEFAULT 0,
        p_empl_rcd       IN     future_dist.empl_rcd%TYPE,
        p_csr            IN OUT SYS_REFCURSOR);

    PROCEDURE get_future_total (p_emplid   IN     future_dist.emplid%TYPE,
                                p_fy       IN     future_dist.fy%TYPE,
                                p_empl_rcd IN future_dist.empl_rcd%type,
                                p_total       OUT future_dist.ucs%TYPE);

    PROCEDURE get_split_list (
        p_emplid         IN     future_dist.emplid%TYPE,
        p_fy             IN     future_dist.fy%TYPE,
        p_viewing_dept   IN     future_dist.key_global_dept%TYPE,
        p_csr            IN OUT SYS_REFCURSOR);

    PROCEDURE get_future_budget (
        p_emplid            IN     fast_pay_actuals.emplid%TYPE,
        p_fy                IN     future_dist.fy%TYPE,
        p_key_global_dept   IN     future_dist.key_global_dept%TYPE,
        p_sum                  OUT fast_pay_actuals.actual_amt%TYPE,
        p_csr               IN OUT SYS_REFCURSOR);

    PROCEDURE get_future_dist_totals (
        p_key_global_dept   IN     future_dist.key_global_dept%TYPE,
        p_fiscalyear        IN     future_dist.fy%TYPE,
        curr_eandg             OUT SYS_REFCURSOR,
        curr_otherfunds        OUT SYS_REFCURSOR,
        curr_fundcodes         OUT SYS_REFCURSOR);

    PROCEDURE get_future_dist_by_dept (
        p_key_global_dept   IN     future_dist.key_global_dept%TYPE,
        p_fy                IN     future_dist.fy%TYPE,
        p_csr               IN OUT SYS_REFCURSOR);

    PROCEDURE get_future_dist_by_emplids (
        p_emplids           IN     VARCHAR2,
        p_key_global_dept   IN     future_dist.key_global_dept%TYPE,
        p_fy                IN     future_dist.fy%TYPE,
        p_csr               IN OUT SYS_REFCURSOR);

    PROCEDURE upd_future_dist (
        p_seq_no            IN future_dist.seq_no%TYPE,
        p_emplid            IN future_dist.emplid%TYPE,
        p_fy                IN future_dist.fy%TYPE,
        p_key_global_dept   IN NUMBER,
        p_ou                IN future_dist.ou%TYPE,
        p_deptid            IN future_dist.deptid%TYPE,
        p_fund_code         IN future_dist.fund_code%TYPE,
        p_account           IN future_dist.account%TYPE,
        p_product           IN future_dist.product%TYPE,
        p_initiative        IN future_dist.initiative%TYPE,
        p_project_id        IN future_dist.project_id%TYPE,
        p_ucs               IN future_dist.ucs%TYPE,
        p_ucs_pcnt          IN future_dist.ucs_pcnt%TYPE,
        p_annual_pay        IN future_dist.pay_rt_annual%TYPE,
        p_reason            IN future_dist.reason%TYPE,
        p_person_id         IN hsc.sd_hsc_directory.person_id%TYPE,
        p_remote            IN VARCHAR2,
        p_emp_type          IN VARCHAR2,
        p_empl_rcd          IN future_dist.empl_rcd%TYPE);

    PROCEDURE upd_split_requests (
        p_seq_no       IN future_dist.seq_no%TYPE,
        p_person_id    IN hsc.sd_hsc_directory.person_id%TYPE,
        p_status       IN split_requests.status%TYPE,
        p_comments     IN split_requests.comments%TYPE,
        p_fund_code    IN future_dist.fund_code%TYPE,
        p_account      IN future_dist.account%TYPE,
        p_product      IN future_dist.product%TYPE,
        p_initiative   IN future_dist.initiative%TYPE,
        p_project_id   IN future_dist.project_id%TYPE);

    PROCEDURE select_dept (
        p_personid         IN     person_userroles_active.person_id%TYPE,
        p_dept             IN     VARCHAR2,
        p_bypasssecurity   IN     NUMBER,
        p_right_context    IN     VARCHAR2,
        p_csr              IN OUT SYS_REFCURSOR);

    PROCEDURE select_last_name (p_last   IN     VARCHAR2,
                                p_csr    IN OUT SYS_REFCURSOR);

    PROCEDURE select_emplid (p_emplid IN VARCHAR2, p_csr IN OUT SYS_REFCURSOR);

    PROCEDURE edit_term_date (p_emplid       IN employee_adj.emplid%TYPE,
                              p_fiscalyear   IN employee_adj.budget_fy%TYPE,
                              p_term_date    IN VARCHAR2,
                              p_empl_rcd     IN gems_job_data.empl_rcd%TYPE);

    PROCEDURE get_term_date (
        p_emplid       IN     fast_pay_actuals.emplid%TYPE,
        p_fiscalyear   IN     employee_adj.budget_fy%TYPE,
        p_empl_rcd     IN     employee_adj.empl_rcd%TYPE,
        p_csr          IN OUT SYS_REFCURSOR);

    PROCEDURE del_future_dist (p_seq_no IN future_dist.seq_no%TYPE);

    PROCEDURE del_future_dists (
        p_emplid            IN future_dist.emplid%TYPE,
        p_emp_type          IN future_dist.sal_admin_plan_code%TYPE,
        p_key_global_dept   IN future_dist.key_global_dept%TYPE,
        p_next_fy           IN future_dist.fy%TYPE,                  --next fy
        p_empl_rcd          IN future_dist.empl_rcd%TYPE);

    PROCEDURE get_other_employees (
        p_home        IN     NUMBER,
        p_pay_date    IN     fast_pay_actuals.pay_date%TYPE,
        p_type        IN     VARCHAR2,
        p_currentfy   IN     VARCHAR2,
        p_csr         IN OUT SYS_REFCURSOR);

    PROCEDURE get_future_other_employees (
        p_home   IN     NUMBER,
        p_type   IN     VARCHAR2,
        p_fy            future_dist.fy%TYPE,                        --next fy,
        p_csr       OUT SYS_REFCURSOR);

    PROCEDURE get_other_dept (
        p_deptid   IN     hsc.gems_dept_profile_mv.gems_dept_code%TYPE,
        p_csr      IN OUT SYS_REFCURSOR);

    PROCEDURE get_fast_from_global (
        p_global_key   IN     hsc.usf_dept_profile_mv.key_global_dept%TYPE,
        p_csr          IN OUT SYS_REFCURSOR);

    PROCEDURE get_eng_totals (
        p_global_key   IN     hsc.gems_dept_profile_mv.key_global_dept%TYPE,
        p_sum_period      OUT fast_pay_actuals.actual_amt%TYPE,
        p_pay_date        OUT fast_pay_actuals.pay_date%TYPE,
        p_csr          IN OUT SYS_REFCURSOR);

    PROCEDURE get_product_by_period (
        p_global_key   IN     hsc.gems_dept_profile_mv.key_global_dept%TYPE,
        p_pay_date     IN     fast_pay_actuals.pay_date%TYPE,
        p_csr          IN OUT SYS_REFCURSOR);

    PROCEDURE get_fund_by_period (
        p_global_key   IN     hsc.gems_dept_profile_mv.key_global_dept%TYPE,
        p_pay_date     IN     fast_pay_actuals.pay_date%TYPE,
        p_csr          IN OUT SYS_REFCURSOR);



    PROCEDURE get_fast_depts (p_csr IN OUT SYS_REFCURSOR);

    PROCEDURE get_fund_codes (p_csr IN OUT SYS_REFCURSOR);

    PROCEDURE get_ous (p_csr IN OUT SYS_REFCURSOR);

    PROCEDURE get_study_status (p_csr IN OUT SYS_REFCURSOR);

    PROCEDURE get_reasons (p_csr IN OUT SYS_REFCURSOR);

    PROCEDURE get_projects (p_csr IN OUT SYS_REFCURSOR);

    PROCEDURE get_statuses (p_csr IN OUT SYS_REFCURSOR);

    PROCEDURE get_global_depts (p_csr IN OUT SYS_REFCURSOR);

    PROCEDURE get_upload_info (p_csr IN OUT SYS_REFCURSOR);

    PROCEDURE check_home_dept (
        p_deptid                fast_pay_actuals.deptid%TYPE,
        p_key_global_dept       hsc.usf_dept_profile_mv.key_global_dept%TYPE,
        r_cnt               OUT NUMBER);

    PROCEDURE get_global_from_fast (
        p_deptid          fast_pay_actuals.deptid%TYPE,
        p_csr      IN OUT SYS_REFCURSOR);

    PROCEDURE get_hsc_rec (
        p_person_id          hsc.sd_hsc_directory.person_id%TYPE,
        p_csr         IN OUT SYS_REFCURSOR);

    PROCEDURE search_share_requests (
        p_send_dept    IN     future_dist.key_global_dept%TYPE,
        p_recv_dept    IN     future_dist.key_global_dept%TYPE,
        p_status       IN     split_requests.status%TYPE,
        p_last_name    IN     VARCHAR2,
        p_emplid       IN     future_dist.emplid%TYPE,
        p_fiscalyear   IN     future_dist.fy%TYPE,
        p_csr          IN OUT SYS_REFCURSOR);

    PROCEDURE search_share_requests_by_send (
        p_send_dept    IN     future_dist.key_global_dept%TYPE,
        p_fiscalyear   IN     future_dist.fy%TYPE,
        p_csr          IN OUT SYS_REFCURSOR);

    PROCEDURE search_share_requests_by_recv (
        p_recv_dept    IN     future_dist.key_global_dept%TYPE,
        p_fiscalyear   IN     future_dist.fy%TYPE,
        p_csr          IN OUT SYS_REFCURSOR);

    PROCEDURE get_fast_depts_by_global (
        p_key_global_dept   IN     NUMBER,
        p_csr               IN OUT SYS_REFCURSOR);

    PROCEDURE get_pg_definitions (p_csr OUT SYS_REFCURSOR);

    PROCEDURE check_dept_access (
        p_personid        IN person_userroles_active.person_id%TYPE,
        p_keyglobaldept   IN person_userroles_active.key_global_dept%TYPE);


    PROCEDURE get_schedule_d (
        p_dept_code   IN     schedule.usf_dept_code%TYPE,
        p_fy          IN     future_dist.fy%TYPE,
        p_form_type   IN     schedule_data_d.form_type%TYPE,
        p_csr         IN OUT SYS_REFCURSOR);

    PROCEDURE get_next_pg_sid (p_pg_next_sid OUT VARCHAR2);

    PROCEDURE get_pg_depreciation_expenses (p_csr OUT SYS_REFCURSOR);


    PROCEDURE get_pg_schedule_b4 (
        p_key_global_dept_code_code   IN     pg_schedule.pg_global_dept_code%TYPE,
        p_fy                          IN     pg_schedule.pg_fiscal_year%TYPE,
        p_form_type                   IN     pg_schedule_b4.form_type%TYPE,
        p_csr                         IN OUT SYS_REFCURSOR);


    PROCEDURE get_pg_schedule_b5 (
        p_key_global_dept_code   IN     pg_schedule.pg_global_dept_code%TYPE,
        p_fy                     IN     pg_schedule.pg_fiscal_year%TYPE,
        p_form_type              IN     pg_schedule_b5.form_type%TYPE,
        p_csr                    IN OUT SYS_REFCURSOR);

    PROCEDURE ins_pg_schedule_b4 (
        p_pgnextseqvalue    IN VARCHAR2,
        p_fy                IN pg_schedule.pg_fiscal_year%TYPE,
        p_key_global_dept   IN pg_schedule.pg_global_dept_code%TYPE,
        p_form_type         IN pg_schedule_b4.form_type%TYPE,
        p_description       IN pg_schedule_b4.description%TYPE,
        p_definition_id     IN pg_schedule_b4.definition_id%TYPE,
        p_to_from_fund      IN pg_schedule_b4.to_from_fund%TYPE,
        p_dept_div_code     IN pg_schedule_b4.dept_div_code%TYPE,
        p_division_code     IN pg_schedule_b4.division_code%TYPE,
        p_entity            IN pg_schedule_b4.entity%TYPE,
        p_amount            IN pg_schedule_b4.amount%TYPE);

    PROCEDURE ins_pg_schedule_b5 (
        p_pgnextseqvalue               IN VARCHAR2,
        p_fy                           IN pg_schedule.pg_fiscal_year%TYPE,
        p_key_global_dept              IN pg_schedule.pg_global_dept_code%TYPE,
        p_form_type                    IN pg_schedule_b5.form_type%TYPE,
        p_description                  IN pg_schedule_b5.purchase_description%TYPE,
        p_purchase_umsa_ammount        IN pg_schedule_b5.purchase_umsa_amount%TYPE,
        p_purchase_mssc_ammount        IN pg_schedule_b5.purchase_mssc_amount%TYPE,
        p_purchase_comments            IN pg_schedule_b5.purchase_comments%TYPE,
        p_expenses_assets_id           IN pg_schedule_b5.expenses_assets_id%TYPE,
        p_expenses_umsa_depreciation   IN pg_schedule_b5.expenses_umsa_depreciation%TYPE,
        p_expenses_mssc_depreciation   IN pg_schedule_b5.expenses_mssc_depreciation%TYPE,
        p_expenses_comments            IN pg_schedule_b5.expenses_comments%TYPE);

    PROCEDURE upd_pg_schedule_b4 (
        p_schedule_id     IN VARCHAR2,
        p_description     IN pg_schedule_b4.description%TYPE,
        p_definition_id   IN pg_schedule_b4.definition_id%TYPE,
        p_to_from_fund    IN pg_schedule_b4.to_from_fund%TYPE,
        p_dept_div_code   IN pg_schedule_b4.dept_div_code%TYPE,
        p_division_code   IN pg_schedule_b4.division_code%TYPE,
        p_entity          IN pg_schedule_b4.entity%TYPE,
        p_amount          IN pg_schedule_b4.amount%TYPE);

    PROCEDURE upd_pg_schedule_b5 (
        p_schedule_id                  IN VARCHAR2,
        p_description                  IN pg_schedule_b5.purchase_description%TYPE,
        p_purchase_umsa_ammount        IN pg_schedule_b5.purchase_umsa_amount%TYPE,
        p_purchase_mssc_ammount        IN pg_schedule_b5.purchase_mssc_amount%TYPE,
        p_purchase_comments            IN pg_schedule_b5.purchase_comments%TYPE,
        p_expenses_assets_id           IN pg_schedule_b5.expenses_assets_id%TYPE,
        p_expenses_umsa_depreciation   IN pg_schedule_b5.expenses_umsa_depreciation%TYPE,
        p_expenses_mssc_depreciation   IN pg_schedule_b5.expenses_mssc_depreciation%TYPE,
        p_expenses_comments            IN pg_schedule_b5.expenses_comments%TYPE);

    PROCEDURE del_pg_schedule_b4 (
        p_schedule_id IN pg_schedule_b4.pg_schedule_id%TYPE);

    PROCEDURE del_pg_schedule_b5 (
        p_schedule_id IN pg_schedule_b5.pg_schedule_id%TYPE);

    PROCEDURE ins_schedule_d (
        p_dept_code           IN schedule.usf_dept_code%TYPE,
        p_fy                  IN schedule.fiscal_year%TYPE,
        p_form_type           IN schedule_data_d.form_type%TYPE,
        p_sponsor_title       IN schedule_data_d.sponsor_title%TYPE,
        p_pi_name             IN schedule_data_d.pi_name%TYPE,
        p_award_start         IN VARCHAR2,
        p_award_end           IN VARCHAR2,
        p_budget_start        IN VARCHAR2,
        p_budget_end          IN VARCHAR2,
        p_banner_account_no   IN schedule_data_d.banner_account_no%TYPE,
        p_fa_pcnt             IN schedule_data_d.fa_pcnt%TYPE,
        p_study_status        IN schedule_data_d.study_status%TYPE,
        p_revenue             IN schedule_data_d.revenue%TYPE,
        p_project_no          IN schedule_data_d.project_no%TYPE,
        p_salary_fringe       IN schedule_data_d.salary_fringe%TYPE,
        p_non_salary_fringe   IN schedule_data_d.non_salary_fringe%TYPE);

    PROCEDURE upd_schedule_d (
        p_schedule_id         IN schedule_data_d.schedule_id%TYPE,
        p_sponsor_title       IN schedule_data_d.sponsor_title%TYPE,
        p_pi_name             IN schedule_data_d.pi_name%TYPE,
        p_award_start         IN VARCHAR2,
        p_award_end           IN VARCHAR2,
        p_budget_start        IN VARCHAR2,
        p_budget_end          IN VARCHAR2,
        p_banner_account_no   IN schedule_data_d.banner_account_no%TYPE,
        p_fa_pcnt             IN schedule_data_d.fa_pcnt%TYPE,
        p_study_status        IN schedule_data_d.study_status%TYPE,
        p_revenue             IN schedule_data_d.revenue%TYPE,
        p_project_no          IN schedule_data_d.project_no%TYPE,
        p_salary_fringe       IN schedule_data_d.salary_fringe%TYPE,
        p_non_salary_fringe   IN schedule_data_d.non_salary_fringe%TYPE);

    PROCEDURE del_schedule_d (
        p_schedule_id IN schedule_data_d.schedule_id%TYPE);

    PROCEDURE get_schedule_k (
        p_dept_code   IN     schedule.usf_dept_code%TYPE,
        p_fy          IN     future_dist.fy%TYPE,
        p_csr         IN OUT SYS_REFCURSOR);
        
    PROCEDURE get_new_schedule_k (
        p_dept_code   IN     schedule.usf_dept_code%TYPE,
        p_fy          IN     future_dist.fy%TYPE,
        p_csr         IN OUT SYS_REFCURSOR);

    PROCEDURE ins_schedule_k (
        p_dept_code           IN schedule.usf_dept_code%TYPE,
        p_fy                  IN schedule.fiscal_year%TYPE,
        p_sponsor_title       IN schedule_data_k.sponsor_title%TYPE,
        p_pi_name             IN schedule_data_k.pi_name%TYPE,
        p_award_start         IN VARCHAR2,
        p_award_end           IN VARCHAR2,
        p_budget_start        IN VARCHAR2,
        p_budget_end          IN VARCHAR2,
        p_fund                IN schedule_data_k.fund%TYPE,
        p_project             IN schedule_data_k.project%TYPE,
        p_banner_account_no   IN schedule_data_k.banner_account_no%TYPE,
        p_amount              IN schedule_data_k.amount%TYPE,
        p_idc_pcnt            IN schedule_data_k.idc_pcnt%TYPE,
        p_salary_fringe       IN schedule_data_k.salary_fringe%TYPE,
        p_non_salary_fringe   IN schedule_data_k.non_salary_fringe%TYPE);

    PROCEDURE upd_schedule_k (
        p_schedule_id         IN schedule_data_k.schedule_id%TYPE,
        p_sponsor_title       IN schedule_data_k.sponsor_title%TYPE,
        p_pi_name             IN schedule_data_k.pi_name%TYPE,
        p_award_start         IN VARCHAR2,
        p_award_end           IN VARCHAR2,
        p_budget_start        IN VARCHAR2,
        p_budget_end          IN VARCHAR2,
        p_fund                IN schedule_data_k.fund%TYPE,
        p_project             IN schedule_data_k.project%TYPE,
        p_banner_account_no   IN schedule_data_k.banner_account_no%TYPE,
        p_amount              IN schedule_data_k.amount%TYPE,
        p_idc_pcnt            IN schedule_data_k.idc_pcnt%TYPE,
        p_salary_fringe       IN schedule_data_k.salary_fringe%TYPE,
        p_non_salary_fringe   IN schedule_data_k.non_salary_fringe%TYPE);

    PROCEDURE del_schedule_k (
        p_schedule_id IN schedule_data_k.schedule_id%TYPE);

    PROCEDURE get_next_sid (p_next_sid OUT NUMBER);

    PROCEDURE get_pg_schedule_types (
      p_fiscal_year IN pg_schedule_type_component_lk.fy_start%type,
      curr_types OUT SYS_REFCURSOR);

    procedure run_pg_contract_roll_over;

    PROCEDURE ins_upd_pg_contract (
        p_pg_contract_id     IN pg_contract.pg_contract_id%TYPE,
        p_key_global_dept    IN pg_contract.key_global_dept%TYPE,
        p_fiscal_year        IN pg_contract.fiscal_year%TYPE,
        p_contract_name      IN pg_contract.contract_name%TYPE,
        p_comments           IN pg_contract.comments%TYPE,
        p_faculty_member     IN pg_contract.faculty_member%TYPE,
        p_umsa_account_num   IN pg_contract.umsa_account_num%TYPE,
        p_start_date         IN pg_contract.start_date%TYPE,
        p_end_date           IN pg_contract.end_date%TYPE,
        p_fixed_variable     IN pg_contract.fixed_variable%TYPE,
        p_auto_renew         IN pg_contract.auto_renew%TYPE,
        p_jul                IN pg_contract.jul%TYPE,
        p_aug                IN pg_contract.aug%TYPE,
        p_sep                IN pg_contract.sep%TYPE,
        p_oct                IN pg_contract.oct%TYPE,
        p_nov                IN pg_contract.nov%TYPE,
        p_dec                IN pg_contract.dec%TYPE,
        p_jan                IN pg_contract.jan%TYPE,
        p_feb                IN pg_contract.feb%TYPE,
        p_mar                IN pg_contract.mar%TYPE,
        p_apr                IN pg_contract.apr%TYPE,
        p_may                IN pg_contract.may%TYPE,
        p_jun                IN pg_contract.jun%TYPE,
        p_updated_by_pid     IN pg_contract.updated_by_pid%TYPE,
        p_roll_to_next_fy    IN pg_contract.roll_to_next_fy%type
        );

    PROCEDURE ins_upd_pg_charges_psr (
        p_pg_charges_id        IN pg_charges_psr.pg_charges_psr_id%TYPE,
        p_key_global_dept      IN pg_charges_psr.pg_key_global_dept%TYPE,
        p_fiscal_year          IN pg_charges_psr.pg_fiscal_year%TYPE,
        p_dept_division_code   IN pg_charges_psr.pg_dept_division_code%TYPE,
        p_provider             IN pg_charges_psr.pg_provider%TYPE,
        p_current_charges      IN pg_charges_psr.pg_current_charges%TYPE,
        p_current_psr          IN pg_charges_psr.pg_current_psr%TYPE,
        p_budget_charges       IN pg_charges_psr.pg_budget_charges%TYPE,
        p_budget_psr           IN pg_charges_psr.pg_budget_psr%TYPE);

    PROCEDURE get_pg_contracts (
        p_key_global_dept   IN     pg_contract.key_global_dept%TYPE,
        p_fiscal_year       IN     pg_contract.fiscal_year%TYPE,
        curr_contracts         OUT SYS_REFCURSOR);

    PROCEDURE del_pg_contracts (p_csv_pg_contract_ids IN VARCHAR2);

    PROCEDURE get_pg_charges_psr (
        p_key_global_dept   IN     pg_contract.key_global_dept%TYPE,
        p_fiscal_year       IN     pg_contract.fiscal_year%TYPE,
        p_charges_psr          OUT SYS_REFCURSOR);

    PROCEDURE del_pg_charges_psr (p_csv_pg_charges_psr_ids IN VARCHAR2);

    PROCEDURE suggest_fund (p_search     IN     VARCHAR2,
                            curr_funds      OUT SYS_REFCURSOR);


    /*procedure set_state_employee_copies (
        p_person_id IN person_userroles_active.person_id%TYPE,
        p_key_global_dept IN gems_job_data_copy.key_global_dept%type,
        p_emp_type IN gems_job_data_copy.emp_type%type,
        p_fiscal_year IN gems_job_data_copy.fiscal_year%type,
        p_emplid IN gems_job_data_copy.emplid%type --optional parameter
    );*/

    PROCEDURE set_state_employee_copies (
        p_key_global_dept   IN gems_job_data_copy.key_global_dept%TYPE,
        p_emp_type          IN gems_job_data_copy.emp_type%TYPE,
        p_fiscal_year       IN gems_job_data_copy.fiscal_year%TYPE,
        p_emplid            IN gems_job_data_copy.emplid%TYPE --optional parameter
                                                             );

    PROCEDURE deactivate_inactive_emp_lines;

    PROCEDURE get_future_dist_active_list (
        p_fy                 IN     future_dist.fy%TYPE,
        p_viewing_dept       IN     future_dist.key_global_dept%TYPE,
        p_salary_plan_code   IN     future_dist.sal_admin_plan_code%TYPE,
        p_sharing_flag       IN     NUMBER DEFAULT 0,
        p_csr                IN OUT SYS_REFCURSOR);

    PROCEDURE set_state_personnel_status (
        p_fy                 IN future_dist.fy%TYPE,
        p_viewing_dept       IN future_dist.key_global_dept%TYPE,
        p_salary_plan_code   IN future_dist.sal_admin_plan_code%TYPE,
        p_status             IN state_personnel_status.st_status%TYPE,
        p_emplid             IN state_personnel_status.emplid%TYPE,
        p_empl_rcd           IN state_personnel_status.empl_rcd%TYPE);



    PROCEDURE del_state_dist_status (
        p_emplid                IN state_personnel_status.emplid%TYPE,
        p_sal_admin_plan_code   IN state_personnel_status.sal_admin_plan_code%TYPE,
        p_key_global_dept       IN state_personnel_status.key_global_dept%TYPE,
        p_fy                    IN state_personnel_status.fy%TYPE,
        p_empl_rcd              IN state_personnel_status.empl_rcd%TYPE);

    PROCEDURE del_pg_dist_status (
        p_employeenumber    IN pg_personnel_status.employeenumber%TYPE,
        p_key_global_dept   IN pg_personnel_status.key_global_dept%TYPE,
        p_fy                IN pg_personnel_status.budget_fy%TYPE);


    PROCEDURE del_state_status_dup (
        p_sal_admin_plan_code   IN state_personnel_status.sal_admin_plan_code%TYPE,
        p_key_global_dept       IN state_personnel_status.key_global_dept%TYPE,
        p_fy                    IN state_personnel_status.fy%TYPE);



    PROCEDURE del_pg_status_dup (
        p_key_global_dept   IN pg_personnel_status.key_global_dept%TYPE,
        p_fy                IN pg_personnel_status.budget_fy%TYPE);


    FUNCTION f_get_state_fringe_percent (
        p_fiscal_year     IN state_fringe_percents.fiscal_year%TYPE,
        p_employee_type   IN state_fringe_percents.employee_type%TYPE,
        p_fund_code       IN VARCHAR2)
        RETURN NUMBER;

    PROCEDURE get_state_fringe_percent (
        p_fiscal_year      IN     state_fringe_percents.fiscal_year%TYPE,
        p_employee_type    IN     state_fringe_percents.employee_type%TYPE,
        p_fund_code        IN     VARCHAR2,
        r_fringe_percent      OUT NUMBER);

    PROCEDURE set_state_division_number (
        p_fiscal_year       IN state_personnel_schd_div.fiscal_year%TYPE,
        p_key_global_dept   IN state_personnel_schd_div.key_global_dept%TYPE,
        p_employee_type     IN state_personnel_schd_div.employee_type%TYPE,
        p_emplid            IN state_personnel_schd_div.emplid%TYPE,
        p_division_number   IN state_personnel_schd_div.division_number%TYPE);

    PROCEDURE set_asf_reqst_dist (
        p_stt_asf_fnd_reqst_cmpnnts_id   IN state_asf_fnd_reqst_cmpnnts.state_asf_fnd_reqst_cmpnnts_id%TYPE,
        p_statefundsrequestid            IN state_asf_fnd_reqst_cmpnnts.statefundsrequestid%TYPE,
        p_hed_code                       IN state_asf_fnd_reqst_cmpnnts.hed_code%TYPE,
        p_rate                           IN state_asf_fnd_reqst_cmpnnts.rate%TYPE,
        p_hours                          IN state_asf_fnd_reqst_cmpnnts.hours%TYPE,
        p_num_pay_periods                IN state_asf_fnd_reqst_cmpnnts.num_pay_periods%TYPE,
        p_annual_rate                    IN state_asf_fnd_reqst_cmpnnts.annual_rate%TYPE,
        p_taxes                          IN state_asf_fnd_reqst_cmpnnts.taxes%TYPE,
        p_benefits                       IN state_asf_fnd_reqst_cmpnnts.benefits%TYPE,
        p_retirement                     IN state_asf_fnd_reqst_cmpnnts.retirement%TYPE,
        p_dept_div_code                  IN state_asf_fnd_reqst_cmpnnts.dept_div_code%TYPE,
        p_division_code                  IN state_asf_fnd_reqst_cmpnnts.division_code%TYPE);

    PROCEDURE del_asf_reqst_dist (
        p_stt_asf_fnd_reqst_cmpnnts_id IN state_asf_fnd_reqst_cmpnnts.state_asf_fnd_reqst_cmpnnts_id%TYPE);

    FUNCTION ins_pg_charges_psr_fromwh (p_fiscalyear IN funds.budget_fy%TYPE)
        RETURN NUMBER;

    PROCEDURE sel_new_fund_share_reqs (
        p_st_funds_request_id   IN     new_fund_split_requests.paydistributionid%TYPE,
        p_fy                    IN     future_dist.fy%TYPE,
        p_viewing_dept          IN     future_dist.key_global_dept%TYPE,
        p_csr                   IN OUT SYS_REFCURSOR);

    PROCEDURE upd_new_split_requests (
        p_pay_distribution_id   IN state_reqst_pay_distributions.paydistributionid%TYPE,
        p_person_id             IN hsc.sd_hsc_directory.person_id%TYPE,
        p_status                IN new_fund_split_requests.status%TYPE,
        p_comments              IN new_fund_split_requests.comments%TYPE,
        p_fund_code             IN state_reqst_pay_distributions.fund_code%TYPE,
        p_account_code          IN state_reqst_pay_distributions.account_code%TYPE,
        p_product_code          IN state_reqst_pay_distributions.product_code%TYPE,
        p_initiative            IN state_reqst_pay_distributions.initiative%TYPE,
        p_project_code          IN state_reqst_pay_distributions.project_code%TYPE);


    PROCEDURE ins_schedule_record (
        p_ou                 IN     schedule.ou%TYPE,
        p_usf_dept_code      IN     schedule.usf_dept_code%TYPE,
        p_budget_fy          IN     schedule.fiscal_year%TYPE,
        p_fund_code          IN     schedule.fund_code%TYPE,
        p_schedule_type_id   IN     schedule.schedule_type_id%TYPE,
        r_schedule_id           OUT schedule.schedule_id%TYPE);

    procedure set_sfr_new_hire_expenses(
        p_SFR_NEW_HIRE_EXPENSES_ID IN OUT SFR_NEW_HIRE_EXPENSES.sfr_new_hire_expenses_id%type,
        p_BUDGET_FY                IN SFR_NEW_HIRE_EXPENSES.budget_fy%type,
        p_KEY_GLOBAL_DEPT          IN SFR_NEW_HIRE_EXPENSES.key_global_dept%type,
        p_SFR_NEW_REQ_TYPE_ID      IN SFR_NEW_HIRE_EXPENSES.SFR_NEW_REQ_TYPE_ID%type,
        p_DESCRIPTION              IN SFR_NEW_HIRE_EXPENSES.description%type,
        p_AMOUNT                   IN SFR_NEW_HIRE_EXPENSES.AMOUNT%type,
        p_POSITION_NUMBER          IN SFR_NEW_HIRE_EXPENSES.position_number%type,
        p_GEMS_ID                  IN SFR_NEW_HIRE_EXPENSES.gems_id%type,
        p_REQ_PERSON_ID            IN SFR_NEW_HIRE_EXPENSES.req_person_id%type,
        p_REQ_DATE                 IN SFR_NEW_HIRE_EXPENSES.req_date%type,
        p_JUSTIFICATION            IN SFR_NEW_HIRE_EXPENSES.justification%type,
        p_EFFECTIVE_DATE           IN SFR_NEW_HIRE_EXPENSES.effective_date%type
    );

  procedure del_sfr_new_hire_expenses(
        p_SFR_NEW_HIRE_EXPENSES_ID IN SFR_NEW_HIRE_EXPENSES.sfr_new_hire_expenses_id%type
    );

 procedure del_sfr_nhe_distribution(
        p_SFR_NHE_DISTRIBUTION_ID IN SFR_NHE_DISTRIBUTION.sfr_nhe_distribution_id%type
    );

   PROCEDURE get_all_sfr_data (
          p_budget_fy              IN     sfr_new_hire_expenses.budget_fy%TYPE,
          p_key_global_dept        IN     sfr_new_hire_expenses.key_global_dept%TYPE,
          curr_sfr_data   OUT SYS_REFCURSOR,
          curr_sfr_req_type_data   OUT SYS_REFCURSOR);

  PROCEDURE sel_sfr_nhe_distribution (
      p_SFR_NEW_HIRE_EXPENSES_ID IN SFR_NEW_HIRE_EXPENSES.sfr_new_hire_expenses_id%type,
      curr_distribution_data   OUT SYS_REFCURSOR
    );

   procedure set_sfr_nhe_distribution(
        p_SFR_NHE_DISTRIBUTION_ID  IN sfr_nhe_distribution.sfr_nhe_distribution_id%type,
        p_SFR_NEW_HIRE_EXPENSES_ID IN sfr_nhe_distribution.sfr_nhe_distribution_id%type,
        p_ou                       IN sfr_nhe_distribution.ou%type,
        p_dept_code                IN sfr_nhe_distribution.dept_code%type,
        p_account_code             IN sfr_nhe_distribution.account_code%type,
        p_product_code             IN sfr_nhe_distribution.product_code%type,
        p_initiative               IN sfr_nhe_distribution.initiative%type,
        p_project_code             IN sfr_nhe_distribution.project_code%type,
        p_fund_code                IN sfr_nhe_distribution.fund_code%type,
        p_AMOUNT                   IN sfr_nhe_distribution.amount%type
    );

PROCEDURE sel_sfr_exist_position_dist (
        p_personid               IN     person_userroles_active.person_id%TYPE,
        p_sfr_existing_positions_id IN sfr_exist_position_dist.sfr_existing_positions_id%TYPE,
        r_stipendfringepercent      OUT misc_settings.stipend_fringe_percent%TYPE,
        r_totalamount               OUT sfr_existing_positions.new_annual_rate%TYPE,
        curr_components             OUT SYS_REFCURSOR);

PROCEDURE ins_sfr_exist_position_dist (
        p_personid                      IN person_userroles_active.person_id%TYPE,
        p_sfr_existing_positions_id     IN sfr_exist_position_dist.sfr_existing_positions_id%TYPE,
        p_ouid                          IN sfr_exist_position_dist.ouid%TYPE,
        p_deptcode                      IN sfr_exist_position_dist.dept_code%TYPE,
        p_fundcode                      IN sfr_exist_position_dist.fund_code%TYPE,
        p_accountcode                   IN sfr_exist_position_dist.account_code%TYPE,
        p_productcode                   IN sfr_exist_position_dist.product_code%TYPE,
        p_initiative                    IN sfr_exist_position_dist.initiative%TYPE,
        p_projectcode                   IN sfr_exist_position_dist.project_code%TYPE,
        p_ucsamount                     IN sfr_exist_position_dist.ucs_dollars%TYPE,
        p_ucspercent                    IN sfr_exist_position_dist.ucs_percent%TYPE,
        p_pay_distribution_type_id      IN sfr_exist_position_dist.paydistributiontypeid%TYPE);

 PROCEDURE upd_sfr_exist_position_dist (
        p_personid                      IN person_userroles_active.person_id%TYPE,
        p_sfr_existing_positions_id     IN sfr_exist_position_dist.sfr_existing_positions_id%TYPE,
        p_sfr_exist_position_dist_id    IN sfr_exist_position_dist.sfr_exist_position_dist_id%TYPE,
        p_ouid                          IN sfr_exist_position_dist.ouid%TYPE,
        p_deptcode                      IN sfr_exist_position_dist.dept_code%TYPE,
        p_fundcode                      IN sfr_exist_position_dist.fund_code%TYPE,
        p_accountcode                   IN sfr_exist_position_dist.account_code%TYPE,
        p_productcode                   IN sfr_exist_position_dist.product_code%TYPE,
        p_initiative                    IN sfr_exist_position_dist.initiative%TYPE,
        p_projectcode                   IN sfr_exist_position_dist.project_code%TYPE,
        p_ucsamount                     IN sfr_exist_position_dist.ucs_dollars%TYPE,
        p_ucspercent                    IN sfr_exist_position_dist.ucs_percent%TYPE,
        p_paydistributiontypeid         IN sfr_exist_position_dist.paydistributiontypeid%TYPE);

 PROCEDURE del_sfr_exist_position_dist (
        p_personid                       IN person_userroles_active.person_id%TYPE,
        p_sfr_existing_positions_id      IN sfr_exist_position_dist.sfr_existing_positions_id%TYPE,
        p_sfr_exist_position_dist_id      IN sfr_exist_position_dist.sfr_exist_position_dist_id%TYPE);

PROCEDURE get_state_request_fringe2 (
        p_class                  IN     state_funds_classes.statefundsclassid%TYPE,
        r_stipendfringepercent      OUT misc_settings.stipend_fringe_percent%TYPE);

PROCEDURE sel_state_fund_requests2 (
        p_key_global_dept               IN     sfr_existing_positions.key_global_dept%TYPE,
        p_sfr_existing_positions_id   IN     sfr_existing_positions.sfr_existing_positions_id%TYPE,
        p_budget_fy                  IN     sfr_existing_positions.budget_fy%TYPE,
        p_csvtype                     IN     VARCHAR2,
        curr_fund_requests         OUT SYS_REFCURSOR);

 PROCEDURE ins_sfr_existing_positions (
        p_personid                  IN     person_userroles_active.person_id%TYPE,
        p_keyglobaldept             IN     sfr_existing_positions.key_global_dept%TYPE,
        p_lastname                  IN     sfr_existing_positions.last_name%TYPE,
        p_firstname                 IN     sfr_existing_positions.first_name%TYPE,
        p_statefundsclassid         IN     sfr_existing_positions.statefundsclassid%TYPE,
        p_positionnbr               IN     sfr_existing_positions.position_nbr%TYPE,
        p_jobtitle                  IN     sfr_existing_positions.job_title%TYPE,
        p_gemsid                    IN     sfr_existing_positions.gemsid%TYPE,
        p_currentannualrate         IN     sfr_existing_positions.current_annual_rate%TYPE,
        p_fundsrequestannual        IN     sfr_existing_positions.funds_request_annual%TYPE,
        p_newannualrate             IN     sfr_existing_positions.new_annual_rate%TYPE,
        p_hiremonth                 IN     sfr_existing_positions.hire_month%TYPE,
        p_sfr_existing_types_id     IN     sfr_existing_positions.sfr_existing_types_id%TYPE,
        p_justificationcomments     IN     sfr_existing_positions.justification_comments%TYPE,
        p_fiscalyear                IN     sfr_existing_positions.budget_fy%TYPE,
        r_sfr_existing_positions_id      OUT sfr_existing_positions.sfr_existing_positions_id%TYPE);

 PROCEDURE upd_sfr_existing_positions (
        p_personid                   IN person_userroles_active.person_id%TYPE,
        p_sfr_existing_positions_id  IN sfr_existing_positions.sfr_existing_positions_id%TYPE,
        p_lastname                   IN sfr_existing_positions.last_name%TYPE,
        p_firstname                  IN sfr_existing_positions.first_name%TYPE,
        p_statefundsclassid          IN sfr_existing_positions.statefundsclassid%TYPE,
        p_positionnbr                IN sfr_existing_positions.position_nbr%TYPE,
        p_jobtitle                   IN sfr_existing_positions.job_title%TYPE,
        p_gemsid                     IN sfr_existing_positions.gemsid%TYPE,
        p_currentannualrate          IN sfr_existing_positions.current_annual_rate%TYPE,
        p_fundsrequestannual         IN sfr_existing_positions.funds_request_annual%TYPE,
        p_newannualrate              IN sfr_existing_positions.new_annual_rate%TYPE,
        p_hiremonth                  IN sfr_existing_positions.hire_month%TYPE,
        p_sfr_existing_types_id      IN sfr_existing_positions.sfr_existing_types_id%TYPE,
        p_justificationcomments      IN sfr_existing_positions.justification_comments%TYPE);

 PROCEDURE del_sfr_existing_positions (
        p_personid                   IN person_userroles_active.person_id%TYPE,
        p_keyglobaldept              IN sfr_existing_positions.key_global_dept%TYPE,
        p_sfr_existing_positions_id  IN sfr_existing_positions.sfr_existing_positions_id%TYPE);



PROCEDURE get_state_funds_classes2 (curr_classes OUT SYS_REFCURSOR);

PROCEDURE get_state_fund_requests2 (
        p_personid           IN     person_userroles_active.person_id%TYPE,
        p_keyglobaldept      IN     state_funds_requests.key_global_dept%TYPE,
        p_fiscalyear         IN     state_funds_requests.budget_fy%TYPE,
        curr_fund_requests      OUT SYS_REFCURSOR);

procedure sel_sfr_existing_types(
        curr_request_types      OUT SYS_REFCURSOR
);

procedure get_cyborg_id_with_mdmid(
      p_mdm_id in cyborg_payroll_data.mdm_id%type,
      r_employeenumber out cyborg_payroll_data.employeenumber%type
   );

  FUNCTION is_fy_locked (p_fy IN NUMBER)
        RETURN NUMBER;

  FUNCTION get_global_dept_name
    (p_key_global_dept IN gems_job_data_copy.key_global_dept%TYPE)
        RETURN hsc.gems_dept_profile_mv.global_dept_name%TYPE
    ;

    PROCEDURE sel_pg_q4_data_flow (
        p_keyglobaldept    IN     person_userroles_active.key_global_dept%TYPE,
        p_context          IN     VARCHAR2,
        p_emplid           IN     cyborg_payroll_data.employeenumber%TYPE,
        p_nextfiscalyear   IN     pg_pay_distribution_dates.fy%TYPE,
        curr_personnel        OUT SYS_REFCURSOR)
    ;

    PROCEDURE sel_pg_q4_proj_sum (
        p_budget_fy         IN     pg_employee_q4_summary.budget_fy%TYPE,
        p_key_global_dept   IN     pg_employee_q4_summary.key_global_dept%TYPE,
        p_div_code          IN     pg_division_level_distribution.div_code%TYPE,
        p_employeenumber    IN     pg_employee_q4_summary.employeenumber%TYPE,
        curr_results        OUT SYS_REFCURSOR)
    ;

 procedure get_sfr_si_ep_fringe_pcnt(
    p_budget_fy IN state_fringe_percents.fiscal_year%TYPE,
    p_employee_type IN STATE_FRINGE_PERCENTS.EMPLOYEE_TYPE%type,
    r_salary_increase_ep_percent OUT STATE_FRINGE_PERCENTS.SALARY_INCREASE_EP_PERCENT%type
  );
  
PROCEDURE get_last_user(
        p_module         IN     VARCHAR2,
        p_currentfy      IN     VARCHAR2,
        p_type           IN     VARCHAR2,
        p_deptID         IN     DB_CALL_AUDIT_LOG.KEY_GLOBAL_DEPT%TYPE,
        r_firstname      OUT    hsc.health_person.first_name%TYPE,
        r_lastname       OUT    hsc.health_person.last_name%TYPE,
        r_insdate        OUT    db_call_audit_log.ins_date%TYPE
);
 PROCEDURE get_global_dept_per_user (
        p_personid         IN     person_userroles_active.person_id%TYPE,
        p_bypasssecurity   IN     NUMBER,
        p_right_context    IN     VARCHAR2,
        p_csr              IN OUT SYS_REFCURSOR
);

PROCEDURE ins_upd_file_upload (
        p_deptid IN file_upload.key_global_dept%TYPE,
        p_mime   IN     file_upload.file_mimetype%TYPE,
        p_ext    IN     file_upload.file_ext%TYPE,
        p_bin    IN     file_upload.file_binary%TYPE,
        r_ret       OUT NUMBER);
        
PROCEDURE get_file_upload (p_deptid    IN     file_upload.key_global_dept%TYPE,
                               r_cur       OUT SYS_REFCURSOR);

PROCEDURE load_schedule_k_table(p_fy   IN schedule.fiscal_year%TYPE);

PROCEDURE load_schedule_l_table(p_fy   IN schedule.fiscal_year%TYPE);

END;