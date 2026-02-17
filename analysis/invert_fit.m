function i_coef = invert_fit(a_coef)

m=a_coef(1);
b=a_coef(2);
m_i=1/m;
b_i=-b/m;
i_coef=[m_i b_i];
