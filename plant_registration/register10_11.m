addpath( 'file_management' );
addpath( genpath( 'third_party/coherent_point_drift/' ) ); % add subdirs
addpath( 'third_party/finite_icp/' );
addpath( '~/Code/filtering/mahalanobis/' );
addpath( '~/Code/PointCloudGenerator' );

filename_0 = '~/Data/PiFiles/20100204-000083-000.3pi';% 0.3pi';
[X0,Y0,Z0,gray_val_0] = import3Pi( filename_0 );
% remove ground plane
idx = find( Z0 < 620 );
X_registered_cloud = [];
Y_registered_cloud = [];
Z_registered_cloud = [];

X = [X0(idx)', Y0(idx)', Z0(idx)' ];

for i=1:11
    
    filename_1 = sprintf( '~/Data/PiFiles/20100204-000083-%03d.3pi', i )

    [X1,Y1,Z1,gray_val_1] = import3Pi( filename_1 );
    % remove ground plane
    idx_1 = find( Z1 < 620 );
    % sans ground plane
    
    Y = [X1(idx_1)', Y1(idx_1)', Z1(idx_1)' ];
    
    R =  [ 0.9101   -0.4080    0.0724 ;
            0.4118    0.8710   -0.2681 ;
              0.0463    0.2738    0.9607 ]
    t = [ 63.3043,  234.5963, -46.8392 ];
    
    % transform once for each scan that we've registered
    %for j=1:i
        Y_dash = R*Y' + repmat(t,size(Y,1),1)';
        Y = Y_dash';
    %end
    %[Y1_new,Y2_new,Y3_new,Transform] = registerToReferenceRangeScan(X,Y,0,50);
    iters_rigid = 30;
    iters_nonrigid = 30;
    %max_registrable_dist = 10;
    [Y1_new,Y2_new,Y3_new] = register_via_surface_subdivision( ...
                                                X,Y,iters_rigid,iters_nonrigid ); %,max_registrable_dist );
    X_registered_cloud = [ X_registered_cloud ;Y1_new ];
    Y_registered_cloud = [ Y_registered_cloud ;Y2_new ];
    Z_registered_cloud = [ Z_registered_cloud ;Y3_new ];
    
    
    %[Y_unreg] = findUnregisteredPoints( X,[Y1_new,Y2_new,Y3_new],5 );
    
    %[Y1_reg,Y2_reg,Y3_reg,Trans] = registerToReferenceRangeScan( ...
    %                                X,Y_unreg,0,50 );
    
    % The output of the registration doesn't move any more.
    % It has already been warped.
    X = [Y1_new, Y2_new, Y3_new];
    % above yields registration to subcloud -- this does whole set
    %X = [ X_registered_cloud;Y_registered_cloud;Z_registered_cloud]'
end