function [GSV] = GSV_calc(LSM,LSV)

GSV = inv(LSM) * LSV;
