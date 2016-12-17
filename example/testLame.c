#include <stdio.h>
#include <stdlib.h>
#include <lame.h>

#define INBUFSIZE 4096
#define MP3BUFSIZE (int) (1.25 * INBUFSIZE) + 7200
#define SAMPLE_RATE_HZ 16000

int encode(char* inPath, char* outPath) {
    int status = 0;
    lame_global_flags* gfp;
    int ret_code;
    FILE* infp;
    FILE* outfp;
    short* input_buffer;
    int input_samples;
    unsigned char* mp3_buffer;
    int mp3_bytes;
    
    gfp = lame_init();
    if (gfp == NULL) {
        printf("lame_init failed\n");
        status = -1;
        goto exit;
    }

	lame_set_mode(gfp, MONO);
	lame_set_in_samplerate(gfp, SAMPLE_RATE_HZ);
	lame_set_VBR_mean_bitrate_kbps(gfp, 24);
	lame_set_num_channels(gfp, 1);
	
    ret_code = lame_init_params(gfp);
    if (ret_code < 0) {
        printf("lame_init_params returned %d\n",ret_code);
        status = -1;
        goto close_lame;
    }
    
    infp = fopen(inPath, "rb");
    outfp = fopen(outPath, "wb");
    
    input_buffer = (short*)malloc(INBUFSIZE*2);
    mp3_buffer = (unsigned char*)malloc(MP3BUFSIZE);

    do{
        input_samples = fread(input_buffer, 2, INBUFSIZE, infp);
        mp3_bytes = lame_encode_buffer(gfp, input_buffer, NULL, input_samples, mp3_buffer, MP3BUFSIZE);
        if (mp3_bytes <0) {
            status = -1;
            goto free_buffers;
        } else if(mp3_bytes > 0) {
            fwrite(mp3_buffer, 1, mp3_bytes, outfp);
        }         
    }while (input_samples == INBUFSIZE);
    
    mp3_bytes = lame_encode_flush(gfp, mp3_buffer, MP3BUFSIZE);
    if (mp3_bytes > 0) {
        fwrite(mp3_buffer, 1, mp3_bytes, outfp);
    }

	lame_mp3_tags_fid(gfp, outfp);
	
free_buffers:
    free(mp3_buffer); 
    free(input_buffer); 
    
    fclose(outfp); 
    fclose(infp); 
close_lame: 
    lame_close(gfp); 
exit: 
    return status; 
}


int main(int argc, char** argv) { 
    if (argc < 3) { 
        printf("usage: lame_test raw-infile mp3-outfile\n"); 
		exit(-1);
    } 
    encode(argv[1], argv[2]); 
    return 0; 
}
