#include <stdio.h>
#include  "mpi.h"
#define N_nodes 8
#define ROOT 0
int data=326;
int Head_Members[N_nodes]={0,1,2,3,4,5,6,7};

void My_Bcast(void *data,int count,MPI_Datatype datatype,int root,MPI_Comm communicator)
{
    int world_rank,world_size;
    MPI_Comm_rank(communicator,&world_rank);
    MPI_Comm_size(communicator,&world_size);
    // seperate head->nodes sum==8
    MPI_Comm Node_comm_world;
    // CHANGE #0
    int color = world_rank%N_nodes;
    int index = world_rank/N_nodes;
    MPI_Comm_split(communicator,color,index,&Node_comm_world);
    // bulid root->head comm
    MPI_Group head_group,world_group;
    MPI_Comm_group(communicator,&world_group);
    MPI_Group_incl(world_group,N_nodes,Head_Members,&head_group);
    // it is for all nodes comm ,include diffrent group
    MPI_Comm head_comm_world;
    MPI_Comm_create(communicator,head_group,&head_comm_world);
    if(world_rank<N_nodes)
    {
        int head_world_rank,head_world_size;
        MPI_Comm_rank(head_comm_world,&head_world_rank);
        MPI_Comm_size(head_comm_world,&head_world_size);
        int dst;
        MPI_Status mpi_status;
        if(head_world_rank==root)
            for(dst=0;dst<head_world_size;dst++)
            {
                //if(dst!=root)
                    MPI_Send(data,count,datatype,dst,0,head_comm_world);
            }
        MPI_Recv(data,count,datatype,root,0,head_comm_world,&mpi_status); 
        // for a same group one node->others
        int node_world_rank,node_world_size;
        MPI_Comm_rank(Node_comm_world,&node_world_rank);
        MPI_Comm_size(Node_comm_world,&node_world_size);
        if(node_world_rank==ROOT)
            for(dst=0;dst<node_world_size;dst++)
                //if(dst!=ROOT)
                    MPI_Send(data,count,datatype,dst,1,Node_comm_world);
    }
    // CHANGE1: root -> 0
    //MPI_Recv(data,count,datatype,root,1,Node_comm_world,MPI_STATUS_IGNORE);
    MPI_Recv(data,count,datatype,0,1,Node_comm_world,MPI_STATUS_IGNORE);
    // \begin DEBUG
    if (world_rank == 0)
        printf("#%d received [%d] from #%d\n", world_rank, *(int *)data, root);
    // \end DEBUG }
}

int main(int argc,char *argv[])
{
    int world_rank,world_size;
    MPI_Status mpi_status;
    MPI_Init(&argc,&argv);
    MPI_Comm_rank(MPI_COMM_WORLD,&world_rank);
    double start_time,end_time;
    double Mpi_Bcast_total_time=0,My_Bcast_total_time=0;
    int root;
    for (root = 0; root <N_nodes; root++)
    {
        start_time=MPI_Wtime();
        MPI_Barrier(MPI_COMM_WORLD);
        MPI_Bcast(&data,1,MPI_INT,root,MPI_COMM_WORLD);
        MPI_Barrier(MPI_COMM_WORLD);
        end_time=MPI_Wtime();
        Mpi_Bcast_total_time+=end_time-start_time;
    }
    for (root = 0; root <N_nodes; root++)
    {
        start_time=MPI_Wtime();
        MPI_Barrier(MPI_COMM_WORLD);
        My_Bcast(&data,1,MPI_INT,root,MPI_COMM_WORLD);
        MPI_Barrier(MPI_COMM_WORLD);
        end_time=MPI_Wtime();
        My_Bcast_total_time+=end_time-start_time;
    }
    if (world_rank == 0) {
        printf(" MPI_Bcast:\t\t[%.3fms]\n", Mpi_Bcast_total_time*1e3 /N_nodes)    ;
        printf("My_Bcast:\t\t[%.3fms]\n", My_Bcast_total_time*1e3 / N_nodes)    ;
        printf("Speedup:\t\t[%.3fx]\n", Mpi_Bcast_total_time / My_Bcast_total_time);
    }
    MPI_Finalize();
    return 0;
}

