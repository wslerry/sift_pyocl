/**
 * \brief gaussian: Initialize a vector with a gaussian function.
 * 
 * This is a 3 part kernel with first the computation of the gaussisan then a parallel 
 * reduction summation and a normalization.
 * This kernel must be run with size == workgroup
 *
 *
 * @param data:        Float pointer to global memory storing the vector.
 * @param sigma:    width of the gaussian
 * @param size:     size of the function
 *
**/

__kernel void
gaussian(            __global     float     *data,
            const                 float     sigma,
            const                 int     SIZE
)
{
    int lid = get_local_id(0);
//    int wd = get_work_dim(0); DEFINE WG are compile time
    //allocate a shared memory of size floats
    __local float gaus[WORKGROUP];
    __local float sum[WORKGROUP];                     
    if(lid < SIZE){
        float x = ((float)lid - ((float)SIZE - 1.0f)/2.0f) / sigma;
        float y = exp(-x * x / 2.0f);
        gaus[lid] = y / sigma / sqrt(2.0f * M_PI_F);
        sum[lid] = gaus[lid];
    }
    else sum[lid] = 0.0f;
    
//    Now we sum all in shared memory
    
    barrier(CLK_LOCAL_MEM_FENCE);
    if (SIZE > 512){
        if (lid < 512) {
            sum[lid] +=  sum[lid + 512];
        }
        barrier(CLK_LOCAL_MEM_FENCE);
    }
    if (SIZE > 256){
        if (lid < 256){
            sum[lid] +=  sum[lid + 256];
        }
        barrier(CLK_LOCAL_MEM_FENCE);	
    }
    if (SIZE > 128){
        if (lid < 128)    {
            sum[lid] +=  sum[lid + 128];
        }
        barrier(CLK_LOCAL_MEM_FENCE);
    }
    if (SIZE > 64){
        if (lid <  64) {
            sum[lid] +=  sum[lid + 64];
        }
        barrier(CLK_LOCAL_MEM_FENCE);
    }
    if (SIZE > 32){
        if (lid <  32) {
        sum[lid] +=  sum[lid + 32];
        }
        barrier(CLK_LOCAL_MEM_FENCE);
    }
    if (SIZE > 16){
        if (lid <  16){
            sum[lid] +=  sum[lid + 16];
        }
        barrier(CLK_LOCAL_MEM_FENCE);
    }
    if  (SIZE > 8){          
        if (lid <  8 ){
            sum[lid] +=  sum[lid + 8 ];
        }
        barrier(CLK_LOCAL_MEM_FENCE);
    }
    if (SIZE > 4 ){    
        if (lid <  4 ){
            sum[lid] +=  sum[lid + 4 ];
        }
        barrier(CLK_LOCAL_MEM_FENCE);
    }
    if (SIZE > 2 ){
    	if (lid <  2 ){
    		sum[lid] +=  sum[lid + 2 ];
    	}
    	barrier(CLK_LOCAL_MEM_FENCE);
    }
    if (lid == 0)
        sum[0] += sum[1];
    barrier(CLK_LOCAL_MEM_FENCE);
//    Now we normalize the gaussian curve
    if(lid < SIZE){
        data[lid] = gaus[lid] / sum[0];
    }
    else {
        data[lid] = 0.0f;
    }
}