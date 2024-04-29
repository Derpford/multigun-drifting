mixin class DampedSpring {
	// The below functions were stolen outright from
	// https://theorangeduck.com/page/spring-roll-call#implicitspringdamper
	// Fucking christ this math is dense.
	float fast_negexp(float x)
    {
        return 1.0 / (1.0 + x + 0.48*x*x + 0.235*x*x*x);
    }

    double, double impl_damp(
        float x, 
        float v, 
        float x_goal, 
        float v_goal, 
        float stiffness, 
        float damping, 
        float dt, 
        float eps = 1e-5f)
    {
        float g = x_goal;
        float q = v_goal;
        float s = stiffness;
        float d = damping;
        float c = g + (d*q) / (s + eps);
        float y = d / 2.0f; 
        
        if (abs(s - (d*d) / 4.0f) < eps) // Critically Damped
        {
            float j0 = x - c;
            float j1 = v + j0*y;
            
            float eydt = fast_negexp(y*dt);
            
            x = j0*eydt + dt*j1*eydt + c;
            v = -y*j0*eydt - y*dt*j1*eydt + j1*eydt;
        }
        else if (s - (d*d) / 4.0f > 0.0) // Under Damped
        {
            float w = sqrt(s - (d*d)/4.0f);
            float j = sqrt(((v + y*(x - c))**2) / (w*w + eps) + ((x - c)**2));
            float p = atan((v + (x - c) * y) / (-(x - c)*w + eps));
            
            j = (x - c) > 0.0f ? j : -j;
            
            float eydt = fast_negexp(y*dt);
            
            x = j*eydt*cos(w*dt + p) + c;
            v = -y*j*eydt*cos(w*dt + p) - w*j*eydt*sin(w*dt + p);
        }
        else if (s - (d*d) / 4.0f < 0.0) // Over Damped
        {
            float y0 = (d + sqrt(d*d - 4*s)) / 2.0f;
            float y1 = (d - sqrt(d*d - 4*s)) / 2.0f;
            float j1 = (c*y0 - x*y0 - v) / (y1 - y0);
            float j0 = x - j1 - c;
            
            float ey0dt = fast_negexp(y0*dt);
            float ey1dt = fast_negexp(y1*dt);

            x = j0*ey0dt + j1*ey1dt + c;
            v = -y0*j0*ey0dt - y1*j1*ey1dt;
        }
        return x,v;
    }
 
	double damp(double x, double v, double xgoal, double vgoal)
	{
		// Takes current position and current velocity and gives
		// a new velocity.
		/*double dt = 1./35.;
		double stiffness = 5.0;
		double damping = 0.001;
		double g = xgoal;
		double q = vgoal;
		v = dt * stiffness * (g - x) + dt * damping * (q - v);
		return v;*/

		[x,v] = impl_damp(x,v,xgoal,vgoal,500.,30,1./35.);
		return v;
	}
}