import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:client/services/upload_video_service.dart';
import 'dart:io';

part 'upload_video_state.dart';

class UploadVideoCubit extends Cubit<UploadVideoState> {
  UploadVideoCubit() : super(UploadVideoInitial());
  final UploadVideoService uploadVideoService = UploadVideoService();

  Future<void> uploadVideo({
    required File thumbnailFile,
    required File videoFile,
    required String title,
    required String description,
    required String visibility,
  }) async {
    emit(UploadVideoLoading());
    try {
    final videoData = await uploadVideoService.getPresignedUrlForVideo();

    final thumbnailData = await uploadVideoService.getPresignedUrlForThumbnail(
      videoData['video_id']
    );

    thumbnailFile = await thumbnailFile.rename(thumbnailData['thumbnail_id']);
    videoFile = await videoFile.rename(videoData['video_id']);

    final isThumbnailUploaded = await uploadVideoService.uploadFileToS3(
      presignedUrl: thumbnailData['url'],
      file: thumbnailFile,
      isVideo: false,
    );

    final isVideoUploaded = await uploadVideoService.uploadFileToS3(
      presignedUrl: videoData['url'],
      file: videoFile,
      isVideo: true,
    );
    
    if(isThumbnailUploaded && isVideoUploaded){
      final isMetaDataUploaded = await uploadVideoService.uploadMetadata(
        title: title,
        description: description,
        visibility: visibility,
        s3Key: videoData['video_id'],
      );
      if(isMetaDataUploaded){
        emit(UploadVideoSuccess());
      } else {
        emit(UploadVideoError('Failed to upload metadata'));
      }
    } else {
      emit(UploadVideoError('Failed to upload video'));
    } 
    } catch (e) {

      emit(UploadVideoError(e.toString()));

    }
     
    

      
  }
}

