build:
	hugo -D

run:
	hugo serve

make prune:
	aws s3 rm s3://$S3_BUCKET/ --recursive

make deploy:
    aws s3 sync public s3://$S3_BUCKET/